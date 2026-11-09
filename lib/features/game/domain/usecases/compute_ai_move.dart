import 'dart:isolate';
import 'dart:math';

import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:checkers_app/features/game/domain/entities/game.dart';
import 'package:checkers_app/features/game/domain/entities/move.dart';
import 'package:checkers_app/features/game/domain/exceptions/game_exception.dart';
import 'package:checkers_app/features/game/domain/services/ai_engine.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:equatable/equatable.dart';

final class ComputeAiMoveParams extends Equatable {
  const ComputeAiMoveParams({required this.game, required this.difficulty});

  final Game game;
  final Difficulty difficulty;

  @override
  List<Object?> get props => [game, difficulty];
}

/// Chooses the computer's move. The search runs in a separate isolate so the
/// UI never drops frames.
class ComputeAiMove implements UseCase<Move, ComputeAiMoveParams> {
  const ComputeAiMove(this._engine, this._random);

  final AiEngine _engine;
  final Random _random;

  /// Upper bound (exclusive) of the seed passed to the isolate.
  static const int maxSeed = 1 << 32;

  /// Throws [GameAlreadyOverException] if the game is finished.
  @override
  Future<Move> call(ComputeAiMoveParams params) async {
    if (params.game.isOver) throw const GameAlreadyOverException();
    final seed = _random.nextInt(maxSeed);
    return _search(_engine, params.game, params.difficulty, seed);
  }

  // Static, so the isolate closure captures only plain immutable data.
  static Future<Move> _search(
    AiEngine engine,
    Game game,
    Difficulty difficulty,
    int seed,
  ) => Isolate.run(() => engine.bestMove(game, difficulty, Random(seed)));
}
