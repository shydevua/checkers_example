import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final easy = LevelStats(wins: 1);
  final medium = LevelStats(losses: 2);
  final hard = LevelStats(draws: 3);
  final stats = GameStats(easy: easy, medium: medium, hard: hard);

  group('GameStats', () {
    test('empty -> every level empty', () {
      expect(GameStats.empty.easy, LevelStats.empty);
      expect(GameStats.empty.medium, LevelStats.empty);
      expect(GameStats.empty.hard, LevelStats.empty);
    });

    test('forDifficulty -> stats of that level', () {
      expect(stats.forDifficulty(Difficulty.easy), easy);
      expect(stats.forDifficulty(Difficulty.medium), medium);
      expect(stats.forDifficulty(Difficulty.hard), hard);
    });

    test('equality uses every level', () {
      expect(GameStats(easy: easy), isNot(GameStats(medium: easy)));
      expect(GameStats(medium: easy), isNot(GameStats(hard: easy)));
      expect(GameStats(hard: easy), isNot(GameStats.empty));
    });

    test('record easy -> only easy changes', () {
      expect(
        stats.record(Difficulty.easy, GameOutcome.win),
        GameStats(easy: LevelStats(wins: 2), medium: medium, hard: hard),
      );
    });

    test('record medium -> only medium changes', () {
      expect(
        stats.record(Difficulty.medium, GameOutcome.loss),
        GameStats(easy: easy, medium: LevelStats(losses: 3), hard: hard),
      );
    });

    test('record hard -> only hard changes', () {
      expect(
        stats.record(Difficulty.hard, GameOutcome.draw),
        GameStats(easy: easy, medium: medium, hard: LevelStats(draws: 4)),
      );
    });
  });
}
