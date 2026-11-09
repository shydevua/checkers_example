import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:checkers_app/features/shared/game_results/game_result.dart';
import 'package:checkers_app/features/shared/game_results/game_result_exception.dart';
import 'package:checkers_app/features/shared/game_results/game_result_recorder.dart';
import 'package:checkers_app/features/shared/game_results/level_stats.dart';

/// Hands a finished game to the results keeper through the core port.
class SaveGameResult implements UseCase<LevelStats, GameResult> {
  const SaveGameResult(this._recorder);

  final GameResultRecorder _recorder;

  /// Throws [GameResultNotSavedException] if the result cannot be saved.
  @override
  Future<LevelStats> call(GameResult params) async => _recorder.record(params);
}
