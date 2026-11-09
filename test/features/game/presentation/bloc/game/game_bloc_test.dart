import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:checkers_app/core/analytics/analytics_event.dart';
import 'package:checkers_app/core/analytics/track_event.dart';
import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/ai_move_delay.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_bloc.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_event.dart';
import 'package:checkers_app/features/game/presentation/bloc/game/game_state.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:checkers_app/features/shared/game_results/game_result.dart';
import 'package:checkers_app/features/shared/game_results/game_result_exception.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockStartNewGame extends Mock implements StartNewGame {}

class _MockSelectSquare extends Mock implements SelectSquare {}

class _MockMakeMove extends Mock implements MakeMove {}

class _MockComputeAiMove extends Mock implements ComputeAiMove {}

class _MockSaveGameResult extends Mock implements SaveGameResult {}

class _MockTrackEvent extends Mock implements TrackEvent {}

class _DefaultObserver extends BlocObserver {
  const _DefaultObserver();
}

class _EventRecorder extends BlocObserver {
  final events = <Object?>[];

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    events.add(event);
    super.onEvent(bloc, event);
  }
}

Position p(int row, int col) => Position(row, col);

void main() {
  late _MockStartNewGame startNewGame;
  late _MockSelectSquare selectSquare;
  late _MockMakeMove makeMove;
  late _MockComputeAiMove computeAiMove;
  late _MockSaveGameResult saveGameResult;
  late _MockTrackEvent trackEvent;

  const rules = CheckersRules();
  const easy = Difficulty.easy;
  const settle = Duration(milliseconds: 20);

  // Opening: human 5,2 -> 4,3, computer replies with its first legal move.
  final newGame = rules.newGame();
  final humanMove = Move([p(5, 2), p(4, 3)]);
  final afterHuman = rules.play(newGame, humanMove);
  final aiMove = afterHuman.legalMoves.first;
  final afterAi = rules.play(afterHuman, aiMove);

  // The human captures the last black piece.
  final winning = rules.gameFrom(
    Board.fromPieces({p(5, 2): Piece.whiteMan, p(4, 3): Piece.blackMan}),
    turn: PieceColor.white,
  );
  final winMove = winning.legalMoves.single;
  final won = rules.play(winning, winMove);

  // The computer captures the last white piece.
  final losing = rules.gameFrom(
    Board.fromPieces({p(4, 3): Piece.whiteMan, p(3, 2): Piece.blackMan}),
    turn: PieceColor.black,
  );
  final lossMove = losing.legalMoves.single;
  final lost = rules.play(losing, lossMove);

  final stats = LevelStats(wins: 1);

  GameInProgress humanTurn(
    Game game, {
    List<Position> path = const [],
    List<Game> history = const [],
    PieceColor color = PieceColor.white,
  }) => GameInProgress(
    difficulty: easy,
    game: game,
    selection: MoveSelection(game.legalMoves, path: path),
    humanColor: color,
    history: history,
  );

  GameInProgress computerTurn(
    Game game, {
    List<Game> history = const [],
    PieceColor color = PieceColor.white,
  }) => GameInProgress(
    difficulty: easy,
    game: game,
    selection: MoveSelection.none,
    humanColor: color,
    aiThinking: true,
    history: history,
  );

  GameBloc build({Duration delay = Duration.zero}) => GameBloc(
    startNewGame,
    selectSquare,
    makeMove,
    computeAiMove,
    saveGameResult,
    trackEvent,
    AiMoveDelay(delay),
  );

  void stubSelect(MoveSelection from, Position at, MoveSelection to) => when(
    () => selectSquare(SelectSquareParams(selection: from, position: at)),
  ).thenAnswer((_) async => to);

  void stubMove(Game game, Move move, Game result) => when(
    () => makeMove(MakeMoveParams(game: game, move: move)),
  ).thenAnswer((_) async => result);

  void stubAi(Game game, Move move) => when(
    () => computeAiMove(ComputeAiMoveParams(game: game, difficulty: easy)),
  ).thenAnswer((_) async => move);

  setUpAll(() => registerFallbackValue(AnalyticsEvent('fallback')));

  setUp(() {
    startNewGame = _MockStartNewGame();
    selectSquare = _MockSelectSquare();
    makeMove = _MockMakeMove();
    computeAiMove = _MockComputeAiMove();
    saveGameResult = _MockSaveGameResult();
    trackEvent = _MockTrackEvent();
    when(() => trackEvent(any())).thenAnswer((_) async {});
  });

  test('initial state -> GameInitial', () {
    expect(build().state, const GameInitial());
  });

  group('GameStarted', () {
    blocTest<GameBloc, GameState>(
      'human moves first -> [InProgress with selectable pieces]',
      setUp: () => when(
        () => startNewGame(const NoParams()),
      ).thenAnswer((_) async => newGame),
      build: build,
      act: (bloc) => bloc.add(const GameStarted(easy)),
      expect: () => [humanTurn(newGame)],
      verify: (_) => verifyZeroInteractions(computeAiMove),
    );

    late _EventRecorder recorder;

    blocTest<GameBloc, GameState>(
      'human moves first -> the bloc does not request a computer move',
      setUp: () {
        recorder = _EventRecorder();
        Bloc.observer = recorder;
        when(
          () => startNewGame(const NoParams()),
        ).thenAnswer((_) async => newGame);
      },
      tearDown: () => Bloc.observer = const _DefaultObserver(),
      build: build,
      act: (bloc) => bloc.add(const GameStarted(easy)),
      verify: (_) => expect(recorder.events, [const GameStarted(easy)]),
    );

    blocTest<GameBloc, GameState>(
      'computer moves first -> the bloc requests a computer move',
      setUp: () {
        recorder = _EventRecorder();
        Bloc.observer = recorder;
        when(
          () => startNewGame(const NoParams()),
        ).thenAnswer((_) async => afterHuman);
        stubAi(afterHuman, aiMove);
        stubMove(afterHuman, aiMove, afterAi);
      },
      tearDown: () => Bloc.observer = const _DefaultObserver(),
      build: build,
      act: (bloc) => bloc.add(const GameStarted(easy)),
      wait: settle,
      verify: (_) => expect(recorder.events, [
        const GameStarted(easy),
        const AiMoveRequested(),
      ]),
    );

    blocTest<GameBloc, GameState>(
      'computer moves first -> [thinking, computer move played]',
      setUp: () {
        when(
          () => startNewGame(const NoParams()),
        ).thenAnswer((_) async => afterHuman);
        stubAi(afterHuman, aiMove);
        stubMove(afterHuman, aiMove, afterAi);
      },
      build: build,
      act: (bloc) => bloc.add(const GameStarted(easy)),
      wait: settle,
      expect: () => [computerTurn(afterHuman), humanTurn(afterAi)],
    );
  });

  group('SquareTapped', () {
    blocTest<GameBloc, GameState>(
      'before the game started -> ignored',
      build: build,
      act: (bloc) => bloc.add(SquareTapped(p(5, 2))),
      expect: () => <GameState>[],
      verify: (_) => verifyZeroInteractions(selectSquare),
    );

    blocTest<GameBloc, GameState>(
      'while the computer thinks -> ignored',
      build: build,
      seed: () => computerTurn(afterHuman),
      act: (bloc) => bloc.add(SquareTapped(p(2, 1))),
      expect: () => <GameState>[],
      verify: (_) => verifyZeroInteractions(selectSquare),
    );

    blocTest<GameBloc, GameState>(
      'incomplete selection -> [InProgress with the new selection]',
      setUp: () => stubSelect(
        MoveSelection(newGame.legalMoves),
        p(5, 2),
        MoveSelection(newGame.legalMoves, path: [p(5, 2)]),
      ),
      build: build,
      seed: () => humanTurn(newGame),
      act: (bloc) => bloc.add(SquareTapped(p(5, 2))),
      expect: () => [
        humanTurn(newGame, path: [p(5, 2)]),
      ],
      verify: (_) => verifyZeroInteractions(makeMove),
    );

    blocTest<GameBloc, GameState>(
      'completed move -> [computer thinking, reply played]',
      setUp: () {
        stubSelect(
          MoveSelection(newGame.legalMoves, path: [p(5, 2)]),
          p(4, 3),
          MoveSelection(newGame.legalMoves, path: [p(5, 2), p(4, 3)]),
        );
        stubMove(newGame, humanMove, afterHuman);
        stubAi(afterHuman, aiMove);
        stubMove(afterHuman, aiMove, afterAi);
      },
      build: build,
      seed: () => humanTurn(newGame, path: [p(5, 2)]),
      act: (bloc) => bloc.add(SquareTapped(p(4, 3))),
      wait: settle,
      expect: () => [
        computerTurn(afterHuman, history: [newGame]),
        humanTurn(afterAi, history: [newGame]),
      ],
      verify: (_) {
        verify(
          () => makeMove(MakeMoveParams(game: newGame, move: humanMove)),
        ).called(1);
        verify(
          () => computeAiMove(
            ComputeAiMoveParams(game: afterHuman, difficulty: easy),
          ),
        ).called(1);
      },
    );

    blocTest<GameBloc, GameState>(
      'winning move -> [GameOver(win), GameOver(win, stats)]',
      setUp: () {
        stubSelect(
          MoveSelection(winning.legalMoves, path: [p(5, 2)]),
          p(3, 4),
          MoveSelection(winning.legalMoves, path: winMove.path),
        );
        stubMove(winning, winMove, won);
        when(
          () => saveGameResult(
            const GameResult(
              difficulty: easy,
              outcome: GameOutcome.win,
            ),
          ),
        ).thenAnswer((_) async => stats);
      },
      build: build,
      seed: () => humanTurn(winning, path: [p(5, 2)]),
      act: (bloc) => bloc.add(SquareTapped(p(3, 4))),
      expect: () => [
        GameOver(difficulty: easy, game: won, outcome: GameOutcome.win),
        GameOver(
          difficulty: easy,
          game: won,
          outcome: GameOutcome.win,
          levelStats: stats,
        ),
      ],
      verify: (_) => verifyZeroInteractions(computeAiMove),
    );

    blocTest<GameBloc, GameState>(
      'result cannot be saved -> [GameOver, GameOver(statsError)]',
      setUp: () {
        stubSelect(
          MoveSelection(winning.legalMoves, path: [p(5, 2)]),
          p(3, 4),
          MoveSelection(winning.legalMoves, path: winMove.path),
        );
        stubMove(winning, winMove, won);
        when(
          () => saveGameResult(
            const GameResult(
              difficulty: easy,
              outcome: GameOutcome.win,
            ),
          ),
        ).thenThrow(const GameResultNotSavedException());
      },
      build: build,
      seed: () => humanTurn(winning, path: [p(5, 2)]),
      act: (bloc) => bloc.add(SquareTapped(p(3, 4))),
      expect: () => [
        GameOver(difficulty: easy, game: won, outcome: GameOutcome.win),
        GameOver(
          difficulty: easy,
          game: won,
          outcome: GameOutcome.win,
          saveError: const GameResultNotSavedException(),
        ),
      ],
    );

    blocTest<GameBloc, GameState>(
      'unexpected error while saving -> not swallowed',
      setUp: () {
        stubSelect(
          MoveSelection(winning.legalMoves, path: [p(5, 2)]),
          p(3, 4),
          MoveSelection(winning.legalMoves, path: winMove.path),
        );
        stubMove(winning, winMove, won);
        when(
          () => saveGameResult(
            const GameResult(
              difficulty: easy,
              outcome: GameOutcome.win,
            ),
          ),
        ).thenThrow(StateError('bug'));
      },
      build: build,
      seed: () => humanTurn(winning, path: [p(5, 2)]),
      act: (bloc) => bloc.add(SquareTapped(p(3, 4))),
      expect: () => [
        GameOver(difficulty: easy, game: won, outcome: GameOutcome.win),
      ],
      errors: () => [isA<StateError>()],
    );

    blocTest<GameBloc, GameState>(
      'IllegalMoveException -> [GameFailure]',
      setUp: () {
        stubSelect(
          MoveSelection(newGame.legalMoves, path: [p(5, 2)]),
          p(4, 3),
          MoveSelection(newGame.legalMoves, path: [p(5, 2), p(4, 3)]),
        );
        when(
          () => makeMove(MakeMoveParams(game: newGame, move: humanMove)),
        ).thenThrow(const IllegalMoveException());
      },
      build: build,
      seed: () => humanTurn(newGame, path: [p(5, 2)]),
      act: (bloc) => bloc.add(SquareTapped(p(4, 3))),
      expect: () => [
        const GameFailure(difficulty: easy, exception: IllegalMoveException()),
      ],
    );

    blocTest<GameBloc, GameState>(
      'unexpected error -> not swallowed',
      setUp: () => when(
        () => selectSquare(
          SelectSquareParams(
            selection: MoveSelection(newGame.legalMoves),
            position: p(5, 2),
          ),
        ),
      ).thenThrow(StateError('bug')),
      build: build,
      seed: () => humanTurn(newGame),
      act: (bloc) => bloc.add(SquareTapped(p(5, 2))),
      expect: () => <GameState>[],
      errors: () => [isA<StateError>()],
    );
  });

  group('AiMoveRequested', () {
    blocTest<GameBloc, GameState>(
      "on the human's turn -> ignored",
      build: build,
      seed: () => humanTurn(newGame),
      act: (bloc) => bloc.add(const AiMoveRequested()),
      expect: () => <GameState>[],
      verify: (_) => verifyZeroInteractions(computeAiMove),
    );

    blocTest<GameBloc, GameState>(
      'before the game started -> ignored',
      build: build,
      act: (bloc) => bloc.add(const AiMoveRequested()),
      expect: () => <GameState>[],
      verify: (_) => verifyZeroInteractions(computeAiMove),
    );

    blocTest<GameBloc, GameState>(
      'computer captures the last piece -> [GameOver(loss), with stats]',
      setUp: () {
        stubAi(losing, lossMove);
        stubMove(losing, lossMove, lost);
        when(
          () => saveGameResult(
            const GameResult(
              difficulty: easy,
              outcome: GameOutcome.loss,
            ),
          ),
        ).thenAnswer((_) async => stats);
      },
      build: build,
      seed: () => computerTurn(losing),
      act: (bloc) => bloc.add(const AiMoveRequested()),
      wait: settle,
      expect: () => [
        GameOver(difficulty: easy, game: lost, outcome: GameOutcome.loss),
        GameOver(
          difficulty: easy,
          game: lost,
          outcome: GameOutcome.loss,
          levelStats: stats,
        ),
      ],
    );

    blocTest<GameBloc, GameState>(
      'reply is not shown before the minimum thinking time',
      setUp: () {
        stubAi(afterHuman, aiMove);
        stubMove(afterHuman, aiMove, afterAi);
      },
      build: () => build(delay: const Duration(milliseconds: 300)),
      seed: () => computerTurn(afterHuman),
      act: (bloc) => bloc.add(const AiMoveRequested()),
      wait: settle,
      expect: () => <GameState>[],
      verify: (_) => verifyZeroInteractions(makeMove),
    );

    blocTest<GameBloc, GameState>(
      'reply is shown after the minimum thinking time',
      setUp: () {
        stubAi(afterHuman, aiMove);
        stubMove(afterHuman, aiMove, afterAi);
      },
      build: () => build(delay: const Duration(milliseconds: 30)),
      seed: () => computerTurn(afterHuman),
      act: (bloc) => bloc.add(const AiMoveRequested()),
      wait: const Duration(milliseconds: 100),
      expect: () => [humanTurn(afterAi)],
    );

    blocTest<GameBloc, GameState>(
      'game restarted while thinking -> stale reply discarded',
      setUp: () {
        final reply = Completer<Move>();
        when(
          () => computeAiMove(
            ComputeAiMoveParams(game: afterHuman, difficulty: easy),
          ),
        ).thenAnswer((_) => reply.future);
        when(() => startNewGame(const NoParams())).thenAnswer((_) async {
          reply.complete(aiMove);
          return newGame;
        });
      },
      build: build,
      seed: () => computerTurn(afterHuman),
      act: (bloc) async {
        bloc.add(const AiMoveRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(const GameStarted(easy));
      },
      wait: settle,
      expect: () => [humanTurn(newGame)],
      verify: (_) => verifyZeroInteractions(makeMove),
    );

    blocTest<GameBloc, GameState>(
      'GameAlreadyOverException -> [GameFailure]',
      setUp: () => when(
        () => computeAiMove(
          ComputeAiMoveParams(game: afterHuman, difficulty: easy),
        ),
      ).thenThrow(const GameAlreadyOverException()),
      build: build,
      seed: () => computerTurn(afterHuman),
      act: (bloc) => bloc.add(const AiMoveRequested()),
      wait: settle,
      expect: () => [
        const GameFailure(
          difficulty: easy,
          exception: GameAlreadyOverException(),
        ),
      ],
    );

    blocTest<GameBloc, GameState>(
      'unexpected error -> not swallowed',
      setUp: () => when(
        () => computeAiMove(
          ComputeAiMoveParams(game: afterHuman, difficulty: easy),
        ),
      ).thenThrow(StateError('bug')),
      build: build,
      seed: () => computerTurn(afterHuman),
      act: (bloc) => bloc.add(const AiMoveRequested()),
      wait: settle,
      expect: () => <GameState>[],
      errors: () => [isA<StateError>()],
    );
  });

  group('playing black', () {
    blocTest<GameBloc, GameState>(
      'human plays black -> computer opens, then the human moves',
      setUp: () {
        when(
          () => startNewGame(const NoParams()),
        ).thenAnswer((_) async => newGame);
        stubAi(newGame, humanMove);
        stubMove(newGame, humanMove, afterHuman);
      },
      build: build,
      act: (bloc) =>
          bloc.add(const GameStarted(easy, humanColor: PieceColor.black)),
      wait: settle,
      expect: () => [
        computerTurn(newGame, color: PieceColor.black),
        humanTurn(afterHuman, color: PieceColor.black),
      ],
    );

    blocTest<GameBloc, GameState>(
      'black loses all pieces -> GameOver(loss) for the human',
      setUp: () {
        stubSelect(
          MoveSelection(winning.legalMoves, path: [p(5, 2)]),
          p(3, 4),
          MoveSelection(winning.legalMoves, path: winMove.path),
        );
        stubMove(winning, winMove, won);
        when(
          () => saveGameResult(
            const GameResult(difficulty: easy, outcome: GameOutcome.loss),
          ),
        ).thenAnswer((_) async => stats);
      },
      build: build,
      // White (the computer here) is to move; seeded as a human turn only
      // to drive the move through the tap handler.
      seed: () => humanTurn(winning, path: [p(5, 2)], color: PieceColor.black),
      act: (bloc) => bloc.add(SquareTapped(p(3, 4))),
      expect: () => [
        GameOver(
          difficulty: easy,
          game: won,
          humanColor: PieceColor.black,
          outcome: GameOutcome.loss,
        ),
        GameOver(
          difficulty: easy,
          game: won,
          humanColor: PieceColor.black,
          outcome: GameOutcome.loss,
          levelStats: stats,
        ),
      ],
    );
  });

  group('MoveUndone', () {
    blocTest<GameBloc, GameState>(
      'after a move and the reply -> back before the human move',
      build: build,
      seed: () => humanTurn(afterAi, history: [newGame]),
      act: (bloc) => bloc.add(const MoveUndone()),
      expect: () => [humanTurn(newGame)],
      verify: (_) => verify(
        () => trackEvent(
          AnalyticsEvent('move_undone', const {'difficulty': 'easy'}),
        ),
      ).called(1),
    );

    blocTest<GameBloc, GameState>(
      'several moves -> only the last one is taken back',
      build: build,
      seed: () => humanTurn(afterAi, history: [winning, newGame]),
      act: (bloc) => bloc.add(const MoveUndone()),
      expect: () => [
        humanTurn(newGame, history: [winning]),
      ],
    );

    blocTest<GameBloc, GameState>(
      'no move made yet -> ignored',
      build: build,
      seed: () => humanTurn(newGame),
      act: (bloc) => bloc.add(const MoveUndone()),
      expect: () => <GameState>[],
      verify: (_) => verifyZeroInteractions(trackEvent),
    );

    blocTest<GameBloc, GameState>(
      'while the computer thinks -> ignored',
      build: build,
      seed: () => computerTurn(afterHuman, history: [newGame]),
      act: (bloc) => bloc.add(const MoveUndone()),
      expect: () => <GameState>[],
    );

    blocTest<GameBloc, GameState>(
      'game over -> ignored',
      build: build,
      seed: () =>
          GameOver(difficulty: easy, game: won, outcome: GameOutcome.win),
      act: (bloc) => bloc.add(const MoveUndone()),
      expect: () => <GameState>[],
    );

    test('canUndo needs a previous move and the human turn', () {
      expect(humanTurn(newGame).canUndo, isFalse);
      expect(humanTurn(afterAi, history: [newGame]).canUndo, isTrue);
      expect(computerTurn(afterHuman, history: [newGame]).canUndo, isFalse);
    });
  });

  group('analytics', () {
    blocTest<GameBloc, GameState>(
      'GameStarted -> game_started with the level',
      setUp: () => when(
        () => startNewGame(const NoParams()),
      ).thenAnswer((_) async => newGame),
      build: build,
      act: (bloc) => bloc.add(const GameStarted(easy)),
      verify: (_) {
        verify(
          () => trackEvent(
            AnalyticsEvent('game_started', const {
              'difficulty': 'easy',
              'color': 'white',
            }),
          ),
        ).called(1);
        verifyNoMoreInteractions(trackEvent);
      },
    );

    blocTest<GameBloc, GameState>(
      'game over -> game_finished with level and outcome',
      setUp: () {
        stubSelect(
          MoveSelection(winning.legalMoves, path: [p(5, 2)]),
          p(3, 4),
          MoveSelection(winning.legalMoves, path: winMove.path),
        );
        stubMove(winning, winMove, won);
        when(
          () => saveGameResult(
            const GameResult(difficulty: easy, outcome: GameOutcome.win),
          ),
        ).thenAnswer((_) async => stats);
      },
      build: build,
      seed: () => humanTurn(winning, path: [p(5, 2)]),
      act: (bloc) => bloc.add(SquareTapped(p(3, 4))),
      verify: (_) {
        verify(
          () => trackEvent(
            AnalyticsEvent('game_finished', const {
              'difficulty': 'easy',
              'outcome': 'win',
            }),
          ),
        ).called(1);
        verifyNoMoreInteractions(trackEvent);
      },
    );

    blocTest<GameBloc, GameState>(
      'moves during the game -> no analytics events',
      setUp: () => stubSelect(
        MoveSelection(newGame.legalMoves),
        p(5, 2),
        MoveSelection(newGame.legalMoves, path: [p(5, 2)]),
      ),
      build: build,
      seed: () => humanTurn(newGame),
      act: (bloc) => bloc.add(SquareTapped(p(5, 2))),
      verify: (_) => verifyZeroInteractions(trackEvent),
    );
  });

  group('states and events', () {
    test('copyWith keeps everything but the selection', () {
      final state = computerTurn(afterHuman);
      expect(state.copyWith(), state);
      expect(
        state.copyWith(selection: MoveSelection(afterHuman.legalMoves)),
        GameInProgress(
          difficulty: easy,
          game: afterHuman,
          selection: MoveSelection(afterHuman.legalMoves),
          aiThinking: true,
        ),
      );
    });

    test('events compare by value', () {
      expect(const GameStarted(easy), const GameStarted(easy));
      expect(
        const GameStarted(easy),
        isNot(const GameStarted(Difficulty.hard)),
      );
      expect(SquareTapped(p(1, 2)), SquareTapped(p(1, 2)));
      expect(
        const GameStarted(easy),
        isNot(const GameStarted(easy, humanColor: PieceColor.black)),
      );
      expect(const MoveUndone(), const MoveUndone());
      expect(const AiMoveRequested(), const AiMoveRequested());
    });
  });
}
