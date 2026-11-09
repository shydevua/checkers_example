import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';

/// Exception -> user text. Exhaustive on purpose: a new exception type does
/// not compile until it has a message.
String gameErrorText(AppLocalizations l10n, GameException e) => switch (e) {
  InvalidPositionException() => l10n.invalidPosition,
  IllegalMoveException() => l10n.illegalMove,
  GameAlreadyOverException() => l10n.gameAlreadyOver,
};
