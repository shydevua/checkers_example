import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:equatable/equatable.dart';

/// Results of the human player against every difficulty level.
final class GameStats extends Equatable {
  const GameStats({
    this.easy = LevelStats.empty,
    this.medium = LevelStats.empty,
    this.hard = LevelStats.empty,
  });

  static const empty = GameStats();

  final LevelStats easy;
  final LevelStats medium;
  final LevelStats hard;

  LevelStats forDifficulty(Difficulty difficulty) => switch (difficulty) {
    Difficulty.easy => easy,
    Difficulty.medium => medium,
    Difficulty.hard => hard,
  };

  /// A copy with one more game of [outcome] against [difficulty].
  GameStats record(Difficulty difficulty, GameOutcome outcome) =>
      switch (difficulty) {
        Difficulty.easy => GameStats(
          easy: easy.record(outcome),
          medium: medium,
          hard: hard,
        ),
        Difficulty.medium => GameStats(
          easy: easy,
          medium: medium.record(outcome),
          hard: hard,
        ),
        Difficulty.hard => GameStats(
          easy: easy,
          medium: medium,
          hard: hard.record(outcome),
        ),
      };

  @override
  List<Object?> get props => [easy, medium, hard];
}
