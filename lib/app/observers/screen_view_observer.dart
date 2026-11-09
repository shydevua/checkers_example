import 'dart:async';

import 'package:checkers_app/core/analytics/analytics.dart';
import 'package:flutter/widgets.dart';

/// Reports every screen the user lands on. Screen names are route names
/// (`AppPaths.*Name`); unnamed routes (dialogs, sheets) are not screens.
class ScreenViewObserver extends NavigatorObserver {
  ScreenViewObserver(this._analytics);

  final Analytics _analytics;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _report(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _report(newRoute);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _report(previousRoute);

  void _report(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name != null) unawaited(_analytics.logScreenView(name));
  }
}
