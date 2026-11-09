import 'dart:math';

import 'package:checkers_app/features/game/domain/entities/board.dart';
import 'package:checkers_app/features/game/domain/entities/piece.dart';
import 'package:checkers_app/features/game/domain/value_objects/position.dart';

/// Zobrist hashing: a 64-bit key per (square, piece kind) and one for the
/// side to move. Equal positions always get equal hashes; different ones
/// collide with negligible probability.
abstract final class Zobrist {
  static const _kinds = 4;

  // Fixed seed: hashes are the same in every isolate and every run.
  static final List<int> _keys = _generate(Random(20261109));
  static final int _blackToMove = _keys.last;

  static List<int> _generate(Random random) => List.unmodifiable([
    for (var i = 0; i < Position.size * Position.size * _kinds + 1; i++)
      (random.nextInt(1 << 32) << 32) ^ random.nextInt(1 << 32),
  ]);

  static int _kind(Piece piece) =>
      (piece.color == PieceColor.white ? 0 : 2) + (piece.isKing ? 1 : 0);

  /// Hash of [board] with [turn] to move.
  static int hash(Board board, PieceColor turn) {
    var hash = turn == PieceColor.black ? _blackToMove : 0;
    for (final position in Position.all) {
      final piece = board.pieceAt(position);
      if (piece != null) hash ^= _keys[position.index * _kinds + _kind(piece)];
    }
    return hash;
  }
}
