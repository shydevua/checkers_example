import 'package:checkers_app/features/game/domain/entities/piece.dart';
import 'package:checkers_app/features/game/domain/value_objects/position.dart';
import 'package:equatable/equatable.dart';

/// Immutable 8x8 board.
final class Board extends Equatable {
  Board._(List<Piece?> squares) : _squares = List.unmodifiable(squares);

  /// A board without pieces.
  factory Board.empty() => Board._(List.filled(_cells, null));

  /// The starting position: black men on rows 0-2, white men on rows 5-7.
  factory Board.initial() => Board._([
    for (final position in Position.all)
      if (!position.isDark)
        null
      else if (position.row < 3)
        Piece.blackMan
      else if (position.row > 4)
        Piece.whiteMan
      else
        null,
  ]);

  /// A board with exactly [pieces].
  ///
  /// Throws [ArgumentError] if a piece stands on a light square.
  factory Board.fromPieces(Map<Position, Piece> pieces) =>
      Board.empty().updated(pieces);

  static const int _cells = Position.size * Position.size;

  final List<Piece?> _squares;

  Piece? pieceAt(Position position) => _squares[position.index];

  bool isEmptyAt(Position position) => _squares[position.index] == null;

  /// Squares occupied by pieces of [color], top-left to bottom-right.
  Iterable<Position> positionsOf(PieceColor color) sync* {
    for (final position in Position.all) {
      if (_squares[position.index]?.color == color) yield position;
    }
  }

  /// Number of pieces of [color] on the board.
  int countOf(PieceColor color) => positionsOf(color).length;

  /// A copy with [changes] applied (`null` empties a square).
  ///
  /// Throws [ArgumentError] if a piece is put on a light square.
  Board updated(Map<Position, Piece?> changes) {
    final squares = List<Piece?>.of(_squares);
    for (final MapEntry(key: position, value: piece) in changes.entries) {
      if (piece != null && !position.isDark) {
        throw ArgumentError.value(position, 'position', 'is a light square');
      }
      squares[position.index] = piece;
    }
    return Board._(squares);
  }

  @override
  List<Object?> get props => [_squares];
}
