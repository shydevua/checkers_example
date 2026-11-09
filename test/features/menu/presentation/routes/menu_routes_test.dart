import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/navigation/app_paths.dart';
import 'package:checkers_app/features/menu/presentation/pages/home_page.dart';
import 'package:checkers_app/features/menu/presentation/routes/menu_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('home path -> HomePage', (tester) async {
    final router = GoRouter(
      initialLocation: AppPaths.home,
      routes: menuRoutes(),
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
    expect(find.byType(HomePage), findsOneWidget);
  });

  test('route is named for analytics', () {
    expect((menuRoutes().single as GoRoute).name, AppPaths.homeName);
  });
}
