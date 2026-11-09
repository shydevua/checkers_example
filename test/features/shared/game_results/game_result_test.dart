import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:checkers_app/features/shared/game_results/game_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('equality by difficulty and outcome', () {
    const result = GameResult(
      difficulty: Difficulty.easy,
      outcome: GameOutcome.win,
    );
    expect(
      result,
      const GameResult(difficulty: Difficulty.easy, outcome: GameOutcome.win),
    );
    expect(
      result,
      isNot(
        const GameResult(difficulty: Difficulty.hard, outcome: GameOutcome.win),
      ),
    );
    expect(
      result,
      isNot(
        const GameResult(
          difficulty: Difficulty.easy,
          outcome: GameOutcome.loss,
        ),
      ),
    );
  });
}
