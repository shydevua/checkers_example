// Plays the main flow on a real device or simulator with the production
// wiring (DI, storage, isolates):
//   flutter test test/integration -d <device>
// On the host (`flutter test`, CI) it is skipped: platform plugins exist
// only on a device.
@Tags(['integration'])
library;

import 'dart:io';

import 'package:checkers_app/app/app.dart';
import 'package:checkers_app/app/di/injection.dart';
import 'package:checkers_app/core/analytics/analytics.dart';
import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/features/game/presentation/pages/widgets/board_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:injectable/injectable.dart' show Environment;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('choose a level, move, get the reply, undo, open stats', (
    tester,
  ) async {
    await configureDependencies(Environment.dev);
    addTearDown(getIt.reset);
    await tester.pumpWidget(App(analytics: getIt<Analytics>()));
    await tester.pumpAndSettle();
    final l10n = AppLocalizations.of(
      tester.element(find.byType(Scaffold).first),
    );

    await tester.tap(find.byKey(const ValueKey('level-easy')));
    await tester.pumpAndSettle();
    expect(find.text(l10n.yourTurn), findsOneWidget);

    // c3-d4 in screen coordinates of the board.
    final board = tester.getRect(
      find.descendant(
        of: find.byType(BoardView),
        matching: find.byType(CustomPaint),
      ),
    );
    final cell = board.width / 8;
    Offset square(int row, int col) =>
        board.topLeft + Offset((col + 0.5) * cell, (row + 0.5) * cell);
    await tester.tapAt(square(5, 2));
    await tester.pump();
    await tester.tapAt(square(4, 3));

    // The computer answers from its isolate.
    await tester.pumpAndSettle();
    final reply = find.byKey(const ValueKey('game-computer-move'));
    for (var i = 0; i < 50 && reply.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.text(l10n.aiThinking), findsNothing);
    expect(find.byKey(const ValueKey('game-computer-move')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('game-undo')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('game-computer-move')), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('home-stats')));
    await tester.pumpAndSettle();
    expect(find.text(l10n.statistics), findsWidgets);
  }, skip: !(Platform.isAndroid || Platform.isIOS));
}
