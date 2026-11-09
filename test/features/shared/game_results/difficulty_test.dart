import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('three levels in increasing strength', () {
    expect(Difficulty.values, [
      Difficulty.easy,
      Difficulty.medium,
      Difficulty.hard,
    ]);
  });
}
