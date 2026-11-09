import 'package:checkers_app/features/game/domain/entities/board.dart';
import 'package:checkers_app/features/game/domain/entities/move.dart';
import 'package:checkers_app/features/game/domain/entities/piece.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:equatable/equatable.dart';

enum GameStatus { ongoing, whiteWon, blackWon, draw }

/// A snapshot of a game. Create it with `CheckersRules`, which computes
/// [legalMoves] and [status] consistently.
final class Game extends Equatable {
  const Game({
    required this.board,
    required this.turn,
    required this.legalMoves,
    this.status = GameStatus.ongoing,
    this.quietKingMoves = 0,
    this.kingEndgameMoves = 0,
    this.repetitions = const {},
    this.lastMove,
  });

  final Board board;

  /// Side to move.
  final PieceColor turn;

  /// Legal moves of [turn]; empty once the game is over.
  final List<Move> legalMoves;

  final GameStatus status;

  /// Consecutive half-moves made by kings without a capture.
  final int quietKingMoves;

  /// Half-moves played while one side has three or more kings against a
  /// lone king.
  final int kingEndgameMoves;

  /// How often each position (Zobrist hash) occurred since the last capture
  /// or man move; earlier positions cannot come back.
  final Map<int, int> repetitions;

  final Move? lastMove;

  bool get isOver => status != GameStatus.ongoing;

  /// Whether the side to move is obliged to capture.
  bool get mustCapture => legalMoves.any((move) => move.isCapture);

  /// The result for [player], or `null` while the game is ongoing.
  GameOutcome? outcomeFor(PieceColor player) => switch (status) {
    GameStatus.ongoing => null,
    GameStatus.draw => GameOutcome.draw,
    GameStatus.whiteWon =>
      player == PieceColor.white ? GameOutcome.win : GameOutcome.loss,
    GameStatus.blackWon =>
      player == PieceColor.black ? GameOutcome.win : GameOutcome.loss,
  };

  @override
  List<Object?> get props => [
    board,
    turn,
    legalMoves,
    status,
    quietKingMoves,
    kingEndgameMoves,
    repetitions,
    lastMove,
  ];
}
