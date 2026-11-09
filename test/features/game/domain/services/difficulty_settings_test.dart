import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('easy -> one half-move, half of the moves random, no clock', () {
    expect(
      Difficulty.easy.settings,
      const SearchSettings(maxDepth: 1, randomMoveChance: 0.5),
    );
  });

  test('medium -> four half-moves, 10% random, no clock', () {
    expect(
      Difficulty.medium.settings,
      const SearchSettings(maxDepth: 4, randomMoveChance: 0.1),
    );
  });

  test('hard -> up to ten half-moves within 1.2 s, never random', () {
    expect(
      Difficulty.hard.settings,
      const SearchSettings(
        maxDepth: 10,
        randomMoveChance: 0,
        timeLimit: Duration(milliseconds: 1200),
      ),
    );
  });

  test('levels get stronger', () {
    final depths = [for (final d in Difficulty.values) d.settings.maxDepth];
    expect(depths, orderedEquals([...depths]..sort()));
  });
}
