import 'package:checkers_app/app/router/app_router.dart';
import 'package:checkers_app/core/analytics/analytics.dart';
import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class App extends StatefulWidget {
  const App({required this.analytics, super.key});

  final Analytics analytics;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createAppRouter(analytics: widget.analytics);
  }

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    onGenerateTitle: (context) => context.l10n.appTitle,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    routerConfig: _router,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
  );
}
