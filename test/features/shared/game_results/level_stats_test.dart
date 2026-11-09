import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:checkers_app/features/shared/game_results/game_result_exception.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelStats', () {
    test('zero counters -> valid and equal to empty', () {
      expect(LevelStats(), LevelStats.empty);
      expect(LevelStats.empty.played, 0);
    });

    test('positive counters -> stored', () {
      final stats = LevelStats(wins: 1, losses: 2, draws: 3);
      expect(stats.wins, 1);
      expect(stats.losses, 2);
      expect(stats.draws, 3);
      expect(stats.played, 6);
    });

    test('negative wins -> InvalidLevelStatsException', () {
      expect(
        () => LevelStats(wins: -1),
        throwsA(const InvalidLevelStatsException()),
      );
    });

    test('negative losses -> InvalidLevelStatsException', () {
      expect(
        () => LevelStats(losses: -1),
        throwsA(const InvalidLevelStatsException()),
      );
    });

    test('negative draws -> InvalidLevelStatsException', () {
      expect(
        () => LevelStats(draws: -1),
        throwsA(const InvalidLevelStatsException()),
      );
    });

    test('equality uses every counter', () {
      expect(LevelStats(wins: 1), isNot(LevelStats(losses: 1)));
      expect(LevelStats(losses: 1), isNot(LevelStats(draws: 1)));
      expect(LevelStats(draws: 1), isNot(LevelStats.empty));
    });

    test('record win -> wins + 1', () {
      expect(
        LevelStats(wins: 1, losses: 2, draws: 3).record(GameOutcome.win),
        LevelStats(wins: 2, losses: 2, draws: 3),
      );
    });

    test('record loss -> losses + 1', () {
      expect(
        LevelStats(wins: 1, losses: 2, draws: 3).record(GameOutcome.loss),
        LevelStats(wins: 1, losses: 3, draws: 3),
      );
    });

    test('record draw -> draws + 1', () {
      expect(
        LevelStats(wins: 1, losses: 2, draws: 3).record(GameOutcome.draw),
        LevelStats(wins: 1, losses: 2, draws: 4),
      );
    });
  });
}
