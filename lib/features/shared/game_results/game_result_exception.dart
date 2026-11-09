import 'package:checkers_app/core/exceptions/app_exception.dart';

/// Exceptions of the game-results contract shared between features.
sealed class GameResultException extends AppException {
  const GameResultException();
}

/// Results counters violate domain rules (e.g. negative values).
final class InvalidLevelStatsException extends GameResultException {
  const InvalidLevelStatsException();
}

/// A finished game could not be added to the results.
final class GameResultNotSavedException extends GameResultException {
  const GameResultNotSavedException();
}
