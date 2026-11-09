import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final board = Board.initial();
  final quiet = Move([Position(5, 2), Position(4, 3)]);
  final capture = Move(
    [Position(5, 2), Position(3, 4)],
    captured: [Position(4, 3)],
  );

  Game game(GameStatus status, {List<Move> moves = const []}) => Game(
    board: board,
    turn: PieceColor.white,
    legalMoves: moves,
    status: status,
  );

  group('Game', () {
    test('defaults -> ongoing, no quiet king moves, no last move', () {
      final g = Game(board: board, turn: PieceColor.white, legalMoves: [quiet]);
      expect(g.status, GameStatus.ongoing);
      expect(g.quietKingMoves, 0);
      expect(g.lastMove, isNull);
      expect(g.isOver, isFalse);
    });

    test('isOver -> true for every finished status', () {
      expect(game(GameStatus.whiteWon).isOver, isTrue);
      expect(game(GameStatus.blackWon).isOver, isTrue);
      expect(game(GameStatus.draw).isOver, isTrue);
    });

    test('mustCapture -> true when the legal moves are captures', () {
      expect(game(GameStatus.ongoing, moves: [capture]).mustCapture, isTrue);
    });

    test('mustCapture -> false for quiet moves or no moves', () {
      expect(game(GameStatus.ongoing, moves: [quiet]).mustCapture, isFalse);
      expect(game(GameStatus.draw).mustCapture, isFalse);
    });

    test('outcomeFor ongoing -> null', () {
      expect(
        game(GameStatus.ongoing, moves: [quiet]).outcomeFor(PieceColor.white),
        isNull,
      );
    });

    test('outcomeFor draw -> draw for both', () {
      expect(
        game(GameStatus.draw).outcomeFor(PieceColor.white),
        GameOutcome.draw,
      );
      expect(
        game(GameStatus.draw).outcomeFor(PieceColor.black),
        GameOutcome.draw,
      );
    });

    test('outcomeFor whiteWon -> win for white, loss for black', () {
      final g = game(GameStatus.whiteWon);
      expect(g.outcomeFor(PieceColor.white), GameOutcome.win);
      expect(g.outcomeFor(PieceColor.black), GameOutcome.loss);
    });

    test('outcomeFor blackWon -> win for black, loss for white', () {
      final g = game(GameStatus.blackWon);
      expect(g.outcomeFor(PieceColor.black), GameOutcome.win);
      expect(g.outcomeFor(PieceColor.white), GameOutcome.loss);
    });

    test('equality uses every field', () {
      final g = Game(board: board, turn: PieceColor.white, legalMoves: [quiet]);
      expect(
        g,
        Game(board: board, turn: PieceColor.white, legalMoves: [quiet]),
      );
      expect(
        g,
        isNot(
          Game(
            board: board,
            turn: PieceColor.white,
            legalMoves: [quiet],
            lastMove: quiet,
          ),
        ),
      );
      expect(
        g,
        isNot(
          Game(
            board: board,
            turn: PieceColor.white,
            legalMoves: [quiet],
            quietKingMoves: 1,
          ),
        ),
      );
    });
  });
}
