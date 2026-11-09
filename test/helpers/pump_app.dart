import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/navigation/app_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// English strings, the default locale of widget tests.
final AppLocalizations l10n = lookupAppLocalizations(const Locale('en'));

extension PumpApp on WidgetTester {
  /// Pumps [child] as the home route of a router that also knows the
  /// shared paths, so navigation can be asserted by the shown location.
  Future<void> pumpApp(Widget child) async {
    view
      ..physicalSize = const Size(800, 1400)
      ..devicePixelRatio = 1;
    addTearDown(view.reset);
    final router = GoRouter(
      initialLocation: '/start',
      routes: [
        GoRoute(path: '/start', builder: (_, _) => child),
        GoRoute(path: AppPaths.home, builder: (_, _) => const Text('home')),
        GoRoute(path: AppPaths.stats, builder: (_, _) => const Text('stats')),
        GoRoute(
          path: AppPaths.game,
          builder: (_, state) => Text(state.uri.toString()),
        ),
      ],
    );
    addTearDown(router.dispose);
    await pumpWidget(
      MaterialApp.router(
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
