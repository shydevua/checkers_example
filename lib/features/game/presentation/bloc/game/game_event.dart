import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:equatable/equatable.dart';

sealed class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

/// Starts (or restarts) a game against [difficulty], the human playing
/// [humanColor].
final class GameStarted extends GameEvent {
  const GameStarted(this.difficulty, {this.humanColor = PieceColor.white});

  final Difficulty difficulty;
  final PieceColor humanColor;

  @override
  List<Object?> get props => [difficulty, humanColor];
}

/// The human tapped [position] on the board.
final class SquareTapped extends GameEvent {
  const SquareTapped(this.position);

  final Position position;

  @override
  List<Object?> get props => [position];
}

/// It is the computer's turn. Added by the bloc itself.
final class AiMoveRequested extends GameEvent {
  const AiMoveRequested();
}

/// The human takes back their last move (and the computer's reply).
final class MoveUndone extends GameEvent {
  const MoveUndone();
}
