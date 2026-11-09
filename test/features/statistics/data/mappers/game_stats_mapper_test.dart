import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:checkers_app/features/statistics/data/dto/game_stats_dto.dart';
import 'package:checkers_app/features/statistics/data/mappers/game_stats_mapper.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const dto = GameStatsDto(
    easy: LevelStatsDto(wins: 1, losses: 2, draws: 3),
    medium: LevelStatsDto(wins: 4, losses: 5, draws: 6),
    hard: LevelStatsDto(wins: 7, losses: 8, draws: 9),
  );
  final stats = GameStats(
    easy: LevelStats(wins: 1, losses: 2, draws: 3),
    medium: LevelStats(wins: 4, losses: 5, draws: 6),
    hard: LevelStats(wins: 7, losses: 8, draws: 9),
  );

  test('dto -> domain', () {
    expect(dto.toDomain(), stats);
  });

  test('domain -> dto', () {
    expect(stats.toDto(), dto);
  });

  test('level dto -> level stats', () {
    expect(
      const LevelStatsDto(wins: 1, losses: 0, draws: 2).toDomain(),
      LevelStats(wins: 1, draws: 2),
    );
  });

  test('negative counter -> StatsCorruptedException', () {
    expect(
      () => const LevelStatsDto(wins: 0, losses: -1, draws: 0).toDomain(),
      throwsA(const StatsCorruptedException()),
    );
  });

  test('negative counter in any level -> StatsCorruptedException', () {
    const broken = GameStatsDto(
      easy: LevelStatsDto(wins: 0, losses: 0, draws: 0),
      medium: LevelStatsDto(wins: 0, losses: 0, draws: 0),
      hard: LevelStatsDto(wins: -5, losses: 0, draws: 0),
    );
    expect(broken.toDomain, throwsA(const StatsCorruptedException()));
  });
}
