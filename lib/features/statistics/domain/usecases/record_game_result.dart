import 'package:checkers_app/features/shared/game_results/game_result.dart';
import 'package:checkers_app/features/shared/game_results/game_result_exception.dart';
import 'package:checkers_app/features/shared/game_results/game_result_recorder.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';
import 'package:checkers_app/features/statistics/domain/exceptions/stats_exception.dart';
import 'package:checkers_app/features/statistics/domain/repositories/stats_repository.dart';

/// Statistics' implementation of the core [GameResultRecorder] port: adds a
/// finished game to the stored totals.
///
/// It is the boundary between features, so it translates the feature's own
/// [StatsException]s into the port's [GameResultNotSavedException].
class RecordGameResult implements GameResultRecorder {
  const RecordGameResult(this._repository);

  final StatsRepository _repository;

  /// Throws [GameResultNotSavedException] if statistics cannot be read or
  /// written.
  @override
  Future<LevelStats> record(GameResult result) async {
    try {
      final stats = await _repository.load();
      final updated = stats.record(result.difficulty, result.outcome);
      await _repository.save(updated);
      return updated.forDifficulty(result.difficulty);
    } on StatsException catch (_, st) {
      Error.throwWithStackTrace(const GameResultNotSavedException(), st);
    }
  }
}
