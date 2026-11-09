import 'package:checkers_app/app/router/app_router.dart';
import 'package:checkers_app/core/analytics/analytics.dart';
import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/navigation/app_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAnalytics extends Mock implements Analytics {}

void main() {
  late _MockAnalytics analytics;

  setUp(() {
    analytics = _MockAnalytics();
    when(() => analytics.logScreenView(any())).thenAnswer((_) async {});
  });

  test('starts on the home path', () {
    final router = createAppRouter(analytics: analytics);
    addTearDown(router.dispose);
    expect(
      router.routeInformationProvider.value.uri.toString(),
      AppPaths.home,
    );
  });

  testWidgets('opening the app -> home screen view', (tester) async {
    final router = createAppRouter(analytics: analytics);
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    await tester.pumpAndSettle();
    verify(() => analytics.logScreenView(AppPaths.homeName)).called(1);
  });
}
