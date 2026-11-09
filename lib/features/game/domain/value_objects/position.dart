import 'package:checkers_app/features/game/domain/exceptions/game_exception.dart';
import 'package:equatable/equatable.dart';

/// A square of the 8x8 board. Row 0 is the top (black's back rank),
/// column 0 is the left edge.
final class Position extends Equatable {
  /// Throws [InvalidPositionException] if [row] or [col] is outside `0..7`.
  factory Position(int row, int col) {
    if (row < 0 || row >= size || col < 0 || col >= size) {
      throw InvalidPositionException(row, col);
    }
    return all[row * size + col];
  }

  const Position._(this.row, this.col);

  /// Number of rows and columns of the board.
  static const size = 8;

  /// Every square, indexed by [index].
  static final List<Position> all = List.unmodifiable([
    for (var row = 0; row < size; row++)
      for (var col = 0; col < size; col++) Position._(row, col),
  ]);

  final int row;
  final int col;

  /// Index of this square in a row-major list of 64 squares.
  int get index => row * size + col;

  /// Square in checkers notation: columns a-h from the left, rows 1-8 from
  /// white's side (the bottom), so the bottom-left square is `a1`.
  String get notation =>
      '${String.fromCharCode(_firstColumn + col)}${size - row}';

  static const _firstColumn = 0x61; // 'a'

  /// Pieces stand only on dark squares.
  bool get isDark => row.isOdd != col.isOdd;

  /// The square shifted by [dRow] and [dCol], or `null` if it is off-board.
  Position? offset(int dRow, int dCol) {
    final r = row + dRow;
    final c = col + dCol;
    if (r < 0 || r >= size || c < 0 || c >= size) return null;
    return all[r * size + c];
  }

  @override
  List<Object?> get props => [row, col];

  // Hot path of the move generator: compare by index instead of building
  // props lists. Same result as the Equatable equality.
  @override
  bool operator ==(Object other) => other is Position && other.index == index;

  @override
  int get hashCode => index;
}
