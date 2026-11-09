import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('three possible outcomes', () {
    expect(GameOutcome.values, [
      GameOutcome.win,
      GameOutcome.loss,
      GameOutcome.draw,
    ]);
  });
}
