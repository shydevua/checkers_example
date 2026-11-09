import 'package:checkers_app/features/shared/game_results/game_result_exception.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:checkers_app/features/statistics/data/dto/game_stats_dto.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';

extension LevelStatsDtoMapper on LevelStatsDto {
  /// Throws [StatsCorruptedException] if the counters violate domain rules.
  LevelStats toDomain() {
    try {
      return LevelStats(wins: wins, losses: losses, draws: draws);
    } on InvalidLevelStatsException catch (_, st) {
      Error.throwWithStackTrace(const StatsCorruptedException(), st);
    }
  }
}

extension GameStatsDtoMapper on GameStatsDto {
  /// Throws [StatsCorruptedException] if the counters violate domain rules.
  GameStats toDomain() => GameStats(
    easy: easy.toDomain(),
    medium: medium.toDomain(),
    hard: hard.toDomain(),
  );
}

extension LevelStatsMapper on LevelStats {
  LevelStatsDto toDto() =>
      LevelStatsDto(wins: wins, losses: losses, draws: draws);
}

extension GameStatsMapper on GameStats {
  GameStatsDto toDto() => GameStatsDto(
    easy: easy.toDto(),
    medium: medium.toDto(),
    hard: hard.toDto(),
  );
}
