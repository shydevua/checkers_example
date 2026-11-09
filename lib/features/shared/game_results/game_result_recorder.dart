import 'package:checkers_app/features/shared/game_results/game_result.dart';
import 'package:checkers_app/features/shared/game_results/game_result_exception.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';

/// Port through which the game hands finished games to whoever keeps the
/// results (the statistics feature), without the two features knowing each
/// other.
// A port between features; implemented elsewhere and mocked in tests.
// ignore: one_member_abstracts
abstract interface class GameResultRecorder {
  /// Adds [result] and returns the new totals for its difficulty.
  ///
  /// Throws [GameResultNotSavedException] if the result cannot be saved.
  Future<LevelStats> record(GameResult result);
}
