import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:equatable/equatable.dart';

/// How the computer searches at one level.
final class SearchSettings extends Equatable {
  const SearchSettings({
    required this.maxDepth,
    required this.randomMoveChance,
    this.timeLimit,
  });

  /// Deepest search in half-moves (pending captures are always finished).
  final int maxDepth;

  /// Probability in `[0, 1)` of playing a random legal move.
  final double randomMoveChance;

  /// Thinking time; the result of the last completed depth is played.
  /// `null` searches to [maxDepth] whatever it takes.
  final Duration? timeLimit;

  @override
  List<Object?> get props => [maxDepth, randomMoveChance, timeLimit];
}

/// What each level means for the computer's search.
extension DifficultySettings on Difficulty {
  SearchSettings get settings => switch (this) {
    Difficulty.easy => const SearchSettings(
      maxDepth: 1,
      randomMoveChance: 0.5,
    ),
    Difficulty.medium => const SearchSettings(
      maxDepth: 4,
      randomMoveChance: 0.1,
    ),
    Difficulty.hard => const SearchSettings(
      maxDepth: 10,
      randomMoveChance: 0,
      timeLimit: Duration(milliseconds: 1200),
    ),
  };
}
