import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:checkers_app/features/game/domain/entities/game.dart';
import 'package:checkers_app/features/game/domain/entities/move.dart';
import 'package:checkers_app/features/game/domain/exceptions/game_exception.dart';
import 'package:checkers_app/features/game/domain/services/checkers_rules.dart';
import 'package:equatable/equatable.dart';

final class MakeMoveParams extends Equatable {
  const MakeMoveParams({required this.game, required this.move});

  final Game game;
  final Move move;

  @override
  List<Object?> get props => [game, move];
}

/// Plays a move for the side to move.
class MakeMove implements UseCase<Game, MakeMoveParams> {
  const MakeMove(this._rules);

  final CheckersRules _rules;

  /// Throws [GameAlreadyOverException] if the game is finished or
  /// [IllegalMoveException] if the move is not legal.
  @override
  Future<Game> call(MakeMoveParams params) async =>
      _rules.play(params.game, params.move);
}
