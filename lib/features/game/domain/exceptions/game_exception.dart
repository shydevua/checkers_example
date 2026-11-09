import 'package:checkers_app/core/exceptions/app_exception.dart';

/// Every exception the game feature can throw.
sealed class GameException extends AppException {
  const GameException();
}

/// A square outside the 8x8 board was requested.
final class InvalidPositionException extends GameException {
  const InvalidPositionException(this.row, this.col);

  final int row;
  final int col;

  @override
  List<Object?> get props => [row, col];
}

/// The move is not one of the legal moves of the current position.
final class IllegalMoveException extends GameException {
  const IllegalMoveException();
}

/// The game has already finished, no more moves can be made.
final class GameAlreadyOverException extends GameException {
  const GameAlreadyOverException();
}
