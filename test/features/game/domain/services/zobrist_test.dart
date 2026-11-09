import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final initial = Board.initial();

  test('same position and side -> same hash', () {
    expect(
      Zobrist.hash(initial, PieceColor.white),
      Zobrist.hash(Board.initial(), PieceColor.white),
    );
  });

  test('side to move changes the hash', () {
    expect(
      Zobrist.hash(initial, PieceColor.white),
      isNot(Zobrist.hash(initial, PieceColor.black)),
    );
  });

  test('an empty white board hashes to 0', () {
    expect(Zobrist.hash(Board.empty(), PieceColor.white), 0);
  });

  test('moving, crowning or recolouring a piece changes the hash', () {
    final man = Board.fromPieces({Position(5, 2): Piece.whiteMan});
    final hashes = {
      Zobrist.hash(man, PieceColor.white),
      Zobrist.hash(
        Board.fromPieces({Position(4, 3): Piece.whiteMan}),
        PieceColor.white,
      ),
      Zobrist.hash(
        Board.fromPieces({Position(5, 2): Piece.whiteKing}),
        PieceColor.white,
      ),
      Zobrist.hash(
        Board.fromPieces({Position(5, 2): Piece.blackMan}),
        PieceColor.white,
      ),
      Zobrist.hash(
        Board.fromPieces({Position(5, 2): Piece.blackKing}),
        PieceColor.white,
      ),
    };
    expect(hashes, hasLength(5));
  });

  test('transposed move orders reach the same hash', () {
    const rules = CheckersRules();
    final a = rules.apply(
      rules.apply(initial, Move([Position(5, 0), Position(4, 1)])),
      Move([Position(5, 6), Position(4, 7)]),
    );
    final b = rules.apply(
      rules.apply(initial, Move([Position(5, 6), Position(4, 7)])),
      Move([Position(5, 0), Position(4, 1)]),
    );
    expect(
      Zobrist.hash(a, PieceColor.black),
      Zobrist.hash(b, PieceColor.black),
    );
  });
}
