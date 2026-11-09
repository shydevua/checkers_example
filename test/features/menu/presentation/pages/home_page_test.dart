import 'package:checkers_app/features/menu/presentation/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/pump_app.dart';

void main() {
  testWidgets('shows title, three levels and statistics', (tester) async {
    await tester.pumpApp(const HomePage());
    expect(find.text(l10n.appTitle), findsOneWidget);
    expect(find.text(l10n.chooseLevel), findsOneWidget);
    expect(find.text(l10n.difficulty('easy')), findsOneWidget);
    expect(find.text(l10n.difficulty('medium')), findsOneWidget);
    expect(find.text(l10n.difficulty('hard')), findsOneWidget);
    expect(find.text(l10n.statistics), findsOneWidget);
  });

  for (final level in ['easy', 'medium', 'hard']) {
    testWidgets('tap $level -> opens /game/$level', (tester) async {
      await tester.pumpApp(const HomePage());
      await tester.tap(find.byKey(ValueKey('level-$level')));
      await tester.pumpAndSettle();
      expect(find.text('/game/$level'), findsOneWidget);
    });
  }

  testWidgets('tap statistics -> opens /stats', (tester) async {
    await tester.pumpApp(const HomePage());
    await tester.tap(find.byKey(const ValueKey('home-stats')));
    await tester.pumpAndSettle();
    expect(find.text('stats'), findsOneWidget);
  });

  testWidgets('choose black, then a level -> game route with the side', (
    tester,
  ) async {
    await tester.pumpApp(const HomePage());
    expect(find.text(l10n.chooseSide), findsOneWidget);
    await tester.tap(find.text(l10n.sideLabel('black')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('level-hard')));
    await tester.pumpAndSettle();
    expect(find.text('/game/hard?color=black'), findsOneWidget);
  });

  testWidgets('accessibility guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpApp(const HomePage());
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
  });

  testWidgets('large text (200%) -> no overflow', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpApp(const HomePage());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
