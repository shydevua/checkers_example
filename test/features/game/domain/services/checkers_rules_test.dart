import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:flutter_test/flutter_test.dart';

Position p(int row, int col) => Position(row, col);

void main() {
  const rules = CheckersRules();
  const white = PieceColor.white;
  const black = PieceColor.black;

  group('newGame', () {
    test('initial board, white to move, ongoing, 7 opening moves', () {
      final game = rules.newGame();
      expect(game.board, Board.initial());
      expect(game.turn, white);
      expect(game.status, GameStatus.ongoing);
      expect(game.quietKingMoves, 0);
      expect(game.lastMove, isNull);
      expect(game.legalMoves, [
        Move([p(5, 0), p(4, 1)]),
        Move([p(5, 2), p(4, 1)]),
        Move([p(5, 2), p(4, 3)]),
        Move([p(5, 4), p(4, 3)]),
        Move([p(5, 4), p(4, 5)]),
        Move([p(5, 6), p(4, 5)]),
        Move([p(5, 6), p(4, 7)]),
      ]);
    });
  });

  group('quiet moves', () {
    test('white man -> one square diagonally up only', () {
      final board = Board.fromPieces({p(5, 2): Piece.whiteMan});
      expect(rules.legalMoves(board, white), [
        Move([p(5, 2), p(4, 1)]),
        Move([p(5, 2), p(4, 3)]),
      ]);
    });

    test('black man -> one square diagonally down only', () {
      final board = Board.fromPieces({p(2, 1): Piece.blackMan});
      expect(rules.legalMoves(board, black), [
        Move([p(2, 1), p(3, 0)]),
        Move([p(2, 1), p(3, 2)]),
      ]);
    });

    test('man next to the edge or a piece -> only free squares', () {
      final board = Board.fromPieces({
        p(5, 0): Piece.whiteMan,
        p(5, 2): Piece.whiteMan,
        p(4, 3): Piece.whiteMan,
      });
      expect(rules.legalMoves(board, white), [
        Move([p(4, 3), p(3, 2)]),
        Move([p(4, 3), p(3, 4)]),
        Move([p(5, 0), p(4, 1)]),
        Move([p(5, 2), p(4, 1)]),
      ]);
    });

    test('king -> flies along every free diagonal until blocked', () {
      final board = Board.fromPieces({
        p(7, 0): Piece.whiteKing,
        p(2, 5): Piece.whiteMan,
      });
      expect(rules.legalMoves(board, white).where((m) => m.from == p(7, 0)), [
        Move([p(7, 0), p(6, 1)]),
        Move([p(7, 0), p(5, 2)]),
        Move([p(7, 0), p(4, 3)]),
        Move([p(7, 0), p(3, 4)]),
      ]);
    });

    test('king in the middle -> moves in all four directions', () {
      final board = Board.fromPieces({p(1, 2): Piece.blackKing});
      expect(rules.legalMoves(board, black), [
        Move([p(1, 2), p(0, 1)]),
        Move([p(1, 2), p(0, 3)]),
        Move([p(1, 2), p(2, 1)]),
        Move([p(1, 2), p(3, 0)]),
        Move([p(1, 2), p(2, 3)]),
        Move([p(1, 2), p(3, 4)]),
        Move([p(1, 2), p(4, 5)]),
        Move([p(1, 2), p(5, 6)]),
        Move([p(1, 2), p(6, 7)]),
      ]);
    });
  });

  group('captures', () {
    test('capture available -> only captures are legal', () {
      final board = Board.fromPieces({
        p(5, 2): Piece.whiteMan,
        p(5, 6): Piece.whiteMan,
        p(4, 3): Piece.blackMan,
      });
      expect(rules.legalMoves(board, white), [
        Move([p(5, 2), p(3, 4)], captured: [p(4, 3)]),
      ]);
    });

    test('man captures backwards', () {
      final board = Board.fromPieces({
        p(3, 2): Piece.whiteMan,
        p(4, 3): Piece.blackMan,
      });
      expect(rules.legalMoves(board, white), [
        Move([p(3, 2), p(5, 4)], captured: [p(4, 3)]),
      ]);
    });

    test('landing square occupied -> no capture', () {
      final board = Board.fromPieces({
        p(5, 2): Piece.whiteMan,
        p(4, 3): Piece.blackMan,
        p(3, 4): Piece.blackMan,
      });
      expect(rules.legalMoves(board, white), [
        Move([p(5, 2), p(4, 1)]),
      ]);
    });

    test('own piece is never captured', () {
      final board = Board.fromPieces({
        p(5, 2): Piece.whiteMan,
        p(4, 3): Piece.whiteMan,
      });
      expect(rules.legalMoves(board, white).every((m) => !m.isCapture), isTrue);
    });

    test('capture next to the edge -> no landing square, no capture', () {
      final board = Board.fromPieces({
        p(1, 2): Piece.whiteMan,
        p(0, 1): Piece.blackMan,
      });
      expect(rules.legalMoves(board, white), [
        Move([p(1, 2), p(0, 3)]),
      ]);
    });

    test('capturing piece must continue the sequence', () {
      final board = Board.fromPieces({
        p(5, 0): Piece.whiteMan,
        p(4, 1): Piece.blackMan,
        p(2, 3): Piece.blackMan,
      });
      expect(rules.legalMoves(board, white), [
        Move([p(5, 0), p(3, 2), p(1, 4)], captured: [p(4, 1), p(2, 3)]),
      ]);
    });

    test('captured piece cannot be jumped twice', () {
      final board = Board.fromPieces({
        p(5, 0): Piece.whiteMan,
        p(4, 1): Piece.blackMan,
      });
      expect(rules.legalMoves(board, white), [
        Move([p(5, 0), p(3, 2)], captured: [p(4, 1)]),
      ]);
    });

    test('choice between sequences is free (shorter one is legal too)', () {
      final board = Board.fromPieces({
        p(5, 2): Piece.whiteMan,
        p(4, 1): Piece.blackMan,
        p(4, 3): Piece.blackMan,
        p(2, 5): Piece.blackMan,
      });
      expect(rules.legalMoves(board, white), [
        Move([p(5, 2), p(3, 0)], captured: [p(4, 1)]),
        Move([p(5, 2), p(3, 4), p(1, 6)], captured: [p(4, 3), p(2, 5)]),
      ]);
    });

    test('man crowned during a capture continues as a king', () {
      final board = Board.fromPieces({
        p(2, 1): Piece.whiteMan,
        p(1, 2): Piece.blackMan,
        p(2, 5): Piece.blackMan,
      });
      expect(rules.legalMoves(board, white), [
        Move([p(2, 1), p(0, 3), p(3, 6)], captured: [p(1, 2), p(2, 5)]),
        Move([p(2, 1), p(0, 3), p(4, 7)], captured: [p(1, 2), p(2, 5)]),
      ]);
    });

    test('king captures from a distance and may land on any free square', () {
      final board = Board.fromPieces({
        p(7, 0): Piece.whiteKing,
        p(4, 3): Piece.blackMan,
      });
      expect(rules.legalMoves(board, white), [
        Move([p(7, 0), p(3, 4)], captured: [p(4, 3)]),
        Move([p(7, 0), p(2, 5)], captured: [p(4, 3)]),
        Move([p(7, 0), p(1, 6)], captured: [p(4, 3)]),
        Move([p(7, 0), p(0, 7)], captured: [p(4, 3)]),
      ]);
    });

    test('king must land where it can continue capturing', () {
      final board = Board.fromPieces({
        p(7, 0): Piece.whiteKing,
        p(4, 3): Piece.blackMan,
        p(3, 6): Piece.blackMan,
      });
      expect(rules.legalMoves(board, white), [
        Move([p(7, 0), p(2, 5), p(4, 7)], captured: [p(4, 3), p(3, 6)]),
      ]);
    });

    test('king cannot jump two pieces standing next to each other', () {
      final board = Board.fromPieces({
        p(7, 0): Piece.whiteKing,
        p(4, 3): Piece.blackMan,
        p(3, 4): Piece.blackMan,
      });
      expect(rules.legalMoves(board, white).any((m) => m.isCapture), isFalse);
    });

    test('king continuing from a distance decides the landing square', () {
      // Only from 3,4 can the king go on, by flying over 4,5 to take 5,6.
      final board = Board.fromPieces({
        p(7, 0): Piece.whiteKing,
        p(4, 3): Piece.blackMan,
        p(5, 6): Piece.blackMan,
      });
      expect(rules.legalMoves(board, white), [
        Move([p(7, 0), p(3, 4), p(6, 7)], captured: [p(4, 3), p(5, 6)]),
      ]);
    });

    test('king turns after a capture to take the next piece', () {
      final board = Board.fromPieces({
        p(6, 1): Piece.whiteKing,
        p(5, 2): Piece.blackMan,
        p(3, 4): Piece.blackMan,
      });
      expect(rules.legalMoves(board, white), [
        Move([p(6, 1), p(4, 3), p(2, 5)], captured: [p(5, 2), p(3, 4)]),
        Move([p(6, 1), p(4, 3), p(1, 6)], captured: [p(5, 2), p(3, 4)]),
        Move([p(6, 1), p(4, 3), p(0, 7)], captured: [p(5, 2), p(3, 4)]),
      ]);
    });

    test('king may pass over its own start square during a capture', () {
      final board = Board.fromPieces({
        p(4, 3): Piece.whiteKing,
        p(5, 2): Piece.blackMan,
        p(2, 3): Piece.blackMan,
        p(3, 6): Piece.blackMan,
        p(5, 6): Piece.blackMan,
      });
      final moves = rules.legalMoves(board, white);
      expect(moves.every((m) => m.isCapture), isTrue);
      expect(
        moves.every((m) => m.captured.toSet().length == m.captured.length),
        isTrue,
      );
    });
  });

  group('apply', () {
    test('quiet move -> piece moved', () {
      final board = Board.fromPieces({p(5, 2): Piece.whiteMan});
      expect(
        rules.apply(board, Move([p(5, 2), p(4, 3)])),
        Board.fromPieces({p(4, 3): Piece.whiteMan}),
      );
    });

    test('capture -> captured pieces removed', () {
      final board = Board.fromPieces({
        p(5, 0): Piece.whiteMan,
        p(4, 1): Piece.blackMan,
        p(2, 3): Piece.blackMan,
      });
      final move = Move(
        [p(5, 0), p(3, 2), p(1, 4)],
        captured: [p(4, 1), p(2, 3)],
      );
      expect(
        rules.apply(board, move),
        Board.fromPieces({p(1, 4): Piece.whiteMan}),
      );
    });

    test('white man reaching row 0 -> crowned', () {
      final board = Board.fromPieces({p(1, 2): Piece.whiteMan});
      expect(
        rules.apply(board, Move([p(1, 2), p(0, 1)])),
        Board.fromPieces({p(0, 1): Piece.whiteKing}),
      );
    });

    test('black man reaching row 7 -> crowned', () {
      final board = Board.fromPieces({p(6, 1): Piece.blackMan});
      expect(
        rules.apply(board, Move([p(6, 1), p(7, 0)])),
        Board.fromPieces({p(7, 0): Piece.blackKing}),
      );
    });

    test('man passing the last row during a capture -> stays a king', () {
      final board = Board.fromPieces({
        p(2, 1): Piece.whiteMan,
        p(1, 2): Piece.blackMan,
        p(2, 5): Piece.blackMan,
      });
      final move = Move(
        [p(2, 1), p(0, 3), p(3, 6)],
        captured: [p(1, 2), p(2, 5)],
      );
      expect(
        rules.apply(board, move),
        Board.fromPieces({p(3, 6): Piece.whiteKing}),
      );
    });

    test('man not reaching the last row -> stays a man', () {
      final board = Board.fromPieces({p(2, 1): Piece.whiteMan});
      expect(
        rules.apply(board, Move([p(2, 1), p(1, 2)])),
        Board.fromPieces({p(1, 2): Piece.whiteMan}),
      );
    });

    test('king stays a king', () {
      final board = Board.fromPieces({p(0, 1): Piece.blackKing});
      expect(
        rules.apply(board, Move([p(0, 1), p(3, 4)])),
        Board.fromPieces({p(3, 4): Piece.blackKing}),
      );
    });
  });

  group('gameFrom', () {
    test('side without pieces -> it lost, no legal moves', () {
      final board = Board.fromPieces({p(5, 2): Piece.whiteMan});
      final game = rules.gameFrom(board, turn: black);
      expect(game.status, GameStatus.whiteWon);
      expect(game.legalMoves, isEmpty);
    });

    test('white without moves -> black won', () {
      final board = Board.fromPieces({
        p(7, 0): Piece.whiteMan,
        p(6, 1): Piece.blackMan,
        p(5, 2): Piece.blackMan,
      });
      expect(rules.gameFrom(board, turn: white).status, GameStatus.blackWon);
    });

    test('${CheckersRules.drawAfterQuietKingMoves - 1} quiet king moves '
        '-> ongoing', () {
      final board = Board.fromPieces({
        p(7, 0): Piece.whiteKing,
        p(0, 7): Piece.blackKing,
      });
      final game = rules.gameFrom(board, turn: white, quietKingMoves: 29);
      expect(game.status, GameStatus.ongoing);
      expect(game.legalMoves, isNotEmpty);
      expect(game.quietKingMoves, 29);
    });

    test('30 quiet king moves -> draw, no legal moves', () {
      final board = Board.fromPieces({
        p(7, 0): Piece.whiteKing,
        p(0, 7): Piece.blackKing,
      });
      final game = rules.gameFrom(board, turn: white, quietKingMoves: 30);
      expect(CheckersRules.drawAfterQuietKingMoves, 30);
      expect(game.status, GameStatus.draw);
      expect(game.legalMoves, isEmpty);
    });

    test('keeps lastMove', () {
      final move = Move([p(5, 2), p(4, 3)]);
      final game = rules.gameFrom(Board.initial(), turn: black, lastMove: move);
      expect(game.lastMove, move);
      expect(game.turn, black);
    });
  });

  group('play', () {
    test('legal move -> next position, opponent to move, lastMove set', () {
      final game = rules.newGame();
      final move = Move([p(5, 2), p(4, 3)]);
      final next = rules.play(game, move);
      expect(next.board, rules.apply(Board.initial(), move));
      expect(next.turn, black);
      expect(next.lastMove, move);
      expect(next.quietKingMoves, 0);
      expect(next.legalMoves, rules.legalMoves(next.board, black));
    });

    test('illegal move -> IllegalMoveException', () {
      expect(
        () => rules.play(rules.newGame(), Move([p(5, 2), p(3, 4)])),
        throwsA(const IllegalMoveException()),
      );
    });

    test('finished game -> GameAlreadyOverException', () {
      final over = rules.gameFrom(
        Board.fromPieces({p(5, 2): Piece.whiteMan}),
        turn: black,
      );
      expect(
        () => rules.play(over, Move([p(5, 2), p(4, 3)])),
        throwsA(const GameAlreadyOverException()),
      );
    });

    test('quiet king move -> quietKingMoves + 1', () {
      final game = rules.gameFrom(
        Board.fromPieces({p(7, 0): Piece.whiteKing, p(0, 7): Piece.blackKing}),
        turn: white,
        quietKingMoves: 4,
      );
      final next = rules.play(game, Move([p(7, 0), p(6, 1)]));
      expect(next.quietKingMoves, 5);
    });

    test('29th quiet king move -> draw on the 30th', () {
      final game = rules.gameFrom(
        Board.fromPieces({p(7, 0): Piece.whiteKing, p(0, 7): Piece.blackKing}),
        turn: white,
        quietKingMoves: 29,
      );
      expect(
        rules.play(game, Move([p(7, 0), p(6, 1)])).status,
        GameStatus.draw,
      );
    });

    test('man move -> quietKingMoves reset', () {
      final game = rules.gameFrom(
        Board.fromPieces({
          p(7, 0): Piece.whiteKing,
          p(5, 2): Piece.whiteMan,
          p(0, 7): Piece.blackKing,
        }),
        turn: white,
        quietKingMoves: 4,
      );
      expect(rules.play(game, Move([p(5, 2), p(4, 3)])).quietKingMoves, 0);
    });

    test('king capture -> quietKingMoves reset', () {
      final game = rules.gameFrom(
        Board.fromPieces({
          p(7, 0): Piece.whiteKing,
          p(4, 3): Piece.blackMan,
          p(0, 1): Piece.blackKing,
        }),
        turn: white,
        quietKingMoves: 4,
      );
      final move = Move([p(7, 0), p(3, 4)], captured: [p(4, 3)]);
      expect(rules.play(game, move).quietKingMoves, 0);
    });

    test('capturing the last piece -> mover wins', () {
      final game = rules.gameFrom(
        Board.fromPieces({p(5, 2): Piece.whiteMan, p(4, 3): Piece.blackMan}),
        turn: white,
      );
      final move = Move([p(5, 2), p(3, 4)], captured: [p(4, 3)]);
      final next = rules.play(game, move);
      expect(next.status, GameStatus.whiteWon);
      expect(next.outcomeFor(white), GameOutcome.win);
    });
  });

  group('draw rules', () {
    // The kings stand on different diagonals: no capture ever arises.
    final kings = rules.gameFrom(
      Board.fromPieces({p(7, 0): Piece.whiteKing, p(0, 1): Piece.blackKing}),
      turn: white,
    );
    Game shuffle(Game game) {
      var g = rules.play(game, Move([p(7, 0), p(6, 1)]));
      g = rules.play(g, Move([p(0, 1), p(1, 0)]));
      g = rules.play(g, Move([p(6, 1), p(7, 0)]));
      return rules.play(g, Move([p(1, 0), p(0, 1)]));
    }

    test('constants', () {
      expect(CheckersRules.drawAfterRepetitions, 3);
      expect(CheckersRules.drawAfterKingEndgameMoves, 30);
    });

    test('new game counts its position once', () {
      expect(rules.newGame().repetitions.values, [1]);
    });

    test('position seen twice -> still ongoing', () {
      final game = shuffle(kings);
      expect(game.status, GameStatus.ongoing);
      expect(game.repetitions.values, contains(2));
    });

    test('position seen three times -> draw', () {
      expect(shuffle(shuffle(kings)).status, GameStatus.draw);
    });

    test('man move -> earlier positions forgotten', () {
      final game = rules.gameFrom(
        Board.fromPieces({
          p(7, 0): Piece.whiteKing,
          p(6, 3): Piece.whiteMan,
          p(0, 7): Piece.blackKing,
        }),
        turn: white,
      );
      final next = rules.play(game, Move([p(6, 3), p(5, 4)]));
      expect(next.repetitions.values, [1]);
    });

    final endgame = Board.fromPieces({
      p(7, 0): Piece.whiteKing,
      p(7, 2): Piece.whiteKing,
      p(7, 4): Piece.whiteKing,
      p(0, 7): Piece.blackKing,
    });

    test('isKingEndgame: three kings against one, either colour', () {
      expect(rules.isKingEndgame(endgame), isTrue);
      expect(
        rules.isKingEndgame(
          Board.fromPieces({
            p(0, 1): Piece.blackKing,
            p(0, 3): Piece.blackKing,
            p(0, 5): Piece.blackKing,
            p(7, 6): Piece.whiteKing,
          }),
        ),
        isTrue,
      );
    });

    test('isKingEndgame: two kings, a man, or two defenders -> no', () {
      expect(
        rules.isKingEndgame(
          Board.fromPieces({
            p(7, 0): Piece.whiteKing,
            p(7, 2): Piece.whiteKing,
            p(0, 7): Piece.blackKing,
          }),
        ),
        isFalse,
      );
      expect(
        rules.isKingEndgame(endgame.updated({p(7, 4): Piece.whiteMan})),
        isFalse,
      );
      expect(
        rules.isKingEndgame(endgame.updated({p(0, 7): Piece.blackMan})),
        isFalse,
      );
      expect(
        rules.isKingEndgame(endgame.updated({p(0, 5): Piece.blackKing})),
        isFalse,
      );
    });

    test('king endgame: counter grows with every move', () {
      final game = rules.gameFrom(endgame, turn: white, kingEndgameMoves: 3);
      expect(
        rules.play(game, Move([p(7, 0), p(6, 1)])).kingEndgameMoves,
        4,
      );
    });

    test('king endgame not won in 15 moves each -> draw', () {
      final game = rules.gameFrom(endgame, turn: white, kingEndgameMoves: 29);
      final next = rules.play(game, Move([p(7, 0), p(6, 1)]));
      expect(next.quietKingMoves, 1);
      expect(next.status, GameStatus.draw);
    });

    test('other material -> counter reset', () {
      final game = rules.gameFrom(
        kings.board,
        turn: white,
        kingEndgameMoves: 7,
      );
      expect(rules.play(game, Move([p(7, 0), p(6, 1)])).kingEndgameMoves, 0);
    });
  });
}
