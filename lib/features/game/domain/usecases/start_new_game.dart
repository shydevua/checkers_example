import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:checkers_app/features/game/domain/entities/game.dart';
import 'package:checkers_app/features/game/domain/services/checkers_rules.dart';

/// Starts a game from the initial position; white moves first.
class StartNewGame implements UseCase<Game, NoParams> {
  const StartNewGame(this._rules);

  final CheckersRules _rules;

  @override
  Future<Game> call(NoParams params) async => _rules.newGame();
}
