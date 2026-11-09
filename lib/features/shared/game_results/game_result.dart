import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:equatable/equatable.dart';

/// A finished game from the human player's point of view.
final class GameResult extends Equatable {
  const GameResult({required this.difficulty, required this.outcome});

  final Difficulty difficulty;
  final GameOutcome outcome;

  @override
  List<Object?> get props => [difficulty, outcome];
}
