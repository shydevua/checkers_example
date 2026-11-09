@Tags(['golden'])
library;

import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/pages/widgets/board_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Position p(int row, int col) => Position(row, col);

void main() {
  const rules = CheckersRules();

  Future<void> golden(
    WidgetTester tester,
    String name, {
    required Board board,
    required MoveSelection selection,
    Move? lastMove,
    bool flipped = false,
  }) async {
    tester.view
      ..physicalSize = const Size(416, 416)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BoardView(
          board: board,
          selection: selection,
          lastMove: lastMove,
          flipped: flipped,
          onSquareTap: (_) {},
        ),
      ),
    );
    await expectLater(
      find.byType(BoardView),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  final game = rules.newGame();

  testWidgets('initial position with movable pieces', (tester) async {
    await golden(
      tester,
      'board_initial',
      board: game.board,
      selection: MoveSelection(game.legalMoves),
    );
  });

  testWidgets('selected piece with its targets', (tester) async {
    await golden(
      tester,
      'board_selected',
      board: game.board,
      selection: MoveSelection(game.legalMoves, path: [p(5, 2)]),
    );
  });

  testWidgets('kings and last move, black at the bottom', (tester) async {
    final board = Board.fromPieces({
      p(4, 3): Piece.whiteKing,
      p(1, 2): Piece.blackKing,
      p(6, 1): Piece.blackMan,
    });
    await golden(
      tester,
      'board_kings_flipped',
      board: board,
      selection: MoveSelection.none,
      lastMove: Move([p(7, 0), p(4, 3)]),
      flipped: true,
    );
  });
}
