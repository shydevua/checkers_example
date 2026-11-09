import 'package:checkers_app/features/game/domain/entities/board.dart';
import 'package:checkers_app/features/game/domain/entities/piece.dart';
import 'package:checkers_app/features/game/domain/value_objects/position.dart';

/// Static evaluation of a position used by the search.
class BoardEvaluator {
  const BoardEvaluator();

  static const manValue = 100;
  static const kingValue = 300;

  /// Bonus per row a man has advanced from its own back rank.
  static const advanceBonus = 4;

  /// Bonus for a piece on one of the 16 central squares.
  static const centerBonus = 6;

  /// Bonus for a man still guarding its own back rank.
  static const backRankBonus = 8;

  /// Score of [board] for [perspective]: positive means [perspective] is
  /// better.
  int evaluate(Board board, PieceColor perspective) {
    var score = 0;
    for (final color in PieceColor.values) {
      final sign = color == perspective ? 1 : -1;
      for (final position in board.positionsOf(color)) {
        score += sign * pieceValue(board.pieceAt(position)!, position);
      }
    }
    return score;
  }

  /// Value of [piece] standing on [position].
  int pieceValue(Piece piece, Position position) {
    final central =
        position.row >= 2 &&
        position.row <= 5 &&
        position.col >= 2 &&
        position.col <= 5;
    final center = central ? centerBonus : 0;
    if (piece.isKing) return kingValue + center;
    final backRank = piece.color.opponent.promotionRow;
    final advanced = (position.row - backRank).abs();
    final guard = advanced == 0 ? backRankBonus : 0;
    return manValue + advanced * advanceBonus + center + guard;
  }
}
