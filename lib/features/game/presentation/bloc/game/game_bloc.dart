import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:checkers_app/core/analytics/track_event.dart';
import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/analytics/game_analytics.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/ai_move_delay.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_event.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_state.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/shared/game_results/game_result.dart';
import 'package:checkers_app/features/shared/game_results/game_result_exception.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  GameBloc(
    this._startNewGame,
    this._selectSquare,
    this._makeMove,
    this._computeAiMove,
    this._saveGameResult,
    this._trackEvent,
    this._aiMoveDelay,
  ) : super(const GameInitial()) {
    on<GameStarted>(_onStarted, transformer: restartable());
    on<SquareTapped>(_onSquareTapped, transformer: sequential());
    on<AiMoveRequested>(_onAiMoveRequested, transformer: droppable());
    on<MoveUndone>(_onMoveUndone, transformer: droppable());
  }

  final StartNewGame _startNewGame;
  final SelectSquare _selectSquare;
  final MakeMove _makeMove;
  final ComputeAiMove _computeAiMove;
  final SaveGameResult _saveGameResult;
  final TrackEvent _trackEvent;
  final AiMoveDelay _aiMoveDelay;

  Future<void> _onStarted(GameStarted event, Emitter<GameState> emit) async {
    final game = await _startNewGame(const NoParams());
    // Fire and forget: analytics never delays the game.
    unawaited(
      _trackEvent(GameAnalytics.started(event.difficulty, event.humanColor)),
    );
    await _advance(
      _Session(event.difficulty, event.humanColor, const []),
      game,
      emit,
    );
  }

  Future<void> _onSquareTapped(
    SquareTapped event,
    Emitter<GameState> emit,
  ) async {
    final current = state;
    if (current is! GameInProgress || current.aiThinking) return;
    try {
      final selection = await _selectSquare(
        SelectSquareParams(
          selection: current.selection,
          position: event.position,
        ),
      );
      final move = selection.completedMove;
      if (move == null) {
        emit(current.copyWith(selection: selection));
        return;
      }
      final game = await _makeMove(
        MakeMoveParams(game: current.game, move: move),
      );
      await _advance(
        _Session.of(current, history: [...current.history, current.game]),
        game,
        emit,
      );
    } on GameException catch (e) {
      emit(GameFailure(difficulty: current.difficulty, exception: e));
    }
  }

  Future<void> _onAiMoveRequested(
    AiMoveRequested event,
    Emitter<GameState> emit,
  ) async {
    final current = state;
    if (current is! GameInProgress || !current.aiThinking) return;
    try {
      final delay = Future<void>.delayed(
        _aiMoveDelay.after(current.game.lastMove),
      );
      final move = await _computeAiMove(
        ComputeAiMoveParams(
          game: current.game,
          difficulty: current.difficulty,
        ),
      );
      await delay;
      // The game was restarted while the computer was thinking.
      if (state != current) return;
      final game = await _makeMove(
        MakeMoveParams(game: current.game, move: move),
      );
      await _advance(_Session.of(current), game, emit);
    } on GameException catch (e) {
      emit(GameFailure(difficulty: current.difficulty, exception: e));
    }
  }

  /// Back to the position before the human's last move.
  void _onMoveUndone(MoveUndone event, Emitter<GameState> emit) {
    final current = state;
    if (current is! GameInProgress || !current.canUndo) return;
    final previous = current.history.last;
    unawaited(_trackEvent(GameAnalytics.undone(current.difficulty)));
    emit(
      GameInProgress(
        difficulty: current.difficulty,
        game: previous,
        selection: MoveSelection(previous.legalMoves),
        humanColor: current.humanColor,
        history: current.history.sublist(0, current.history.length - 1),
      ),
    );
  }

  /// Emits the state for [game] and hands the turn to whoever moves next.
  Future<void> _advance(
    _Session session,
    Game game,
    Emitter<GameState> emit,
  ) async {
    if (game.isOver) return _finish(session, game, emit);
    final computerTurn = game.turn != session.humanColor;
    emit(
      GameInProgress(
        difficulty: session.difficulty,
        game: game,
        selection: computerTurn
            ? MoveSelection.none
            : MoveSelection(game.legalMoves),
        humanColor: session.humanColor,
        aiThinking: computerTurn,
        history: session.history,
      ),
    );
    if (computerTurn) add(const AiMoveRequested());
  }

  Future<void> _finish(
    _Session session,
    Game game,
    Emitter<GameState> emit,
  ) async {
    final difficulty = session.difficulty;
    final outcome = game.outcomeFor(session.humanColor)!;
    GameOver over({LevelStats? levelStats, GameResultNotSavedException? e}) =>
        GameOver(
          difficulty: difficulty,
          game: game,
          humanColor: session.humanColor,
          outcome: outcome,
          levelStats: levelStats,
          saveError: e,
        );
    emit(over());
    unawaited(_trackEvent(GameAnalytics.finished(difficulty, outcome)));
    try {
      final levelStats = await _saveGameResult(
        GameResult(difficulty: difficulty, outcome: outcome),
      );
      emit(over(levelStats: levelStats));
    } on GameResultNotSavedException catch (e) {
      emit(over(e: e));
    }
  }
}

/// What stays the same between the positions of one game.
final class _Session {
  const _Session(this.difficulty, this.humanColor, this.history);

  _Session.of(GameInProgress state, {List<Game>? history})
    : this(state.difficulty, state.humanColor, history ?? state.history);

  final Difficulty difficulty;
  final PieceColor humanColor;
  final List<Game> history;
}
