import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:checkers_app/features/shared/game_results/game_result_exception.dart';
import 'package:equatable/equatable.dart';

/// Results against one difficulty level.
final class LevelStats extends Equatable {
  /// Throws [InvalidLevelStatsException] if any counter is negative.
  factory LevelStats({int wins = 0, int losses = 0, int draws = 0}) {
    if (wins < 0 || losses < 0 || draws < 0) {
      throw const InvalidLevelStatsException();
    }
    return LevelStats._(wins, losses, draws);
  }

  const LevelStats._(this.wins, this.losses, this.draws);

  static const empty = LevelStats._(0, 0, 0);

  final int wins;
  final int losses;
  final int draws;

  int get played => wins + losses + draws;

  /// A copy with one more game of [outcome].
  LevelStats record(GameOutcome outcome) => switch (outcome) {
    GameOutcome.win => LevelStats._(wins + 1, losses, draws),
    GameOutcome.loss => LevelStats._(wins, losses + 1, draws),
    GameOutcome.draw => LevelStats._(wins, losses, draws + 1),
  };

  @override
  List<Object?> get props => [wins, losses, draws];
}
