import 'package:equatable/equatable.dart';

/// Side of a piece. White starts at the bottom (rows 5-7) and moves first.
enum PieceColor {
  white,
  black;

  PieceColor get opponent => switch (this) {
    PieceColor.white => PieceColor.black,
    PieceColor.black => PieceColor.white,
  };

  /// Row delta of a forward step for a man of this color.
  int get forward => switch (this) {
    PieceColor.white => -1,
    PieceColor.black => 1,
  };

  /// Row where a man of this color is crowned.
  int get promotionRow => switch (this) {
    PieceColor.white => 0,
    PieceColor.black => 7,
  };
}

/// A man or a king of one color.
final class Piece extends Equatable {
  const Piece(this.color, {this.isKing = false});

  static const whiteMan = Piece(PieceColor.white);
  static const blackMan = Piece(PieceColor.black);
  static const whiteKing = Piece(PieceColor.white, isKing: true);
  static const blackKing = Piece(PieceColor.black, isKing: true);

  final PieceColor color;
  final bool isKing;

  Piece crowned() => Piece(color, isKing: true);

  @override
  List<Object?> get props => [color, isKing];
}
