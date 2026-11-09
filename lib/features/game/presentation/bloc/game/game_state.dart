import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:checkers_app/features/shared/game_results/game_result_exception.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:equatable/equatable.dart';

sealed class GameState extends Equatable {
  const GameState();

  @override
  List<Object?> get props => [];
}

final class GameInitial extends GameState {
  const GameInitial();
}

final class GameInProgress extends GameState {
  const GameInProgress({
    required this.difficulty,
    required this.game,
    required this.selection,
    this.humanColor = PieceColor.white,
    this.aiThinking = false,
    this.history = const [],
  });

  final Difficulty difficulty;
  final Game game;

  /// Side the human plays.
  final PieceColor humanColor;

  /// What the human has selected; [MoveSelection.none] on the computer's turn.
  final MoveSelection selection;
  final bool aiThinking;

  /// Positions before each of the human's moves, oldest first.
  final List<Game> history;

  /// A move can be taken back on the human's turn once one was made.
  bool get canUndo => !aiThinking && history.isNotEmpty;

  GameInProgress copyWith({MoveSelection? selection}) => GameInProgress(
    difficulty: difficulty,
    game: game,
    selection: selection ?? this.selection,
    humanColor: humanColor,
    aiThinking: aiThinking,
    history: history,
  );

  @override
  List<Object?> get props => [
    difficulty,
    game,
    selection,
    humanColor,
    aiThinking,
    history,
  ];
}

final class GameOver extends GameState {
  const GameOver({
    required this.difficulty,
    required this.game,
    required this.outcome,
    this.humanColor = PieceColor.white,
    this.levelStats,
    this.saveError,
  });

  final Difficulty difficulty;
  final Game game;
  final PieceColor humanColor;

  /// Result for the human player.
  final GameOutcome outcome;

  /// Totals against [difficulty] once the result is saved.
  final LevelStats? levelStats;

  /// Why the result could not be saved.
  final GameResultNotSavedException? saveError;

  @override
  List<Object?> get props => [
    difficulty,
    game,
    humanColor,
    outcome,
    levelStats,
    saveError,
  ];
}

final class GameFailure extends GameState {
  const GameFailure({required this.difficulty, required this.exception});

  final Difficulty difficulty;
  final GameException exception;

  @override
  List<Object?> get props => [difficulty, exception];
}
