import 'package:checkers_app/core/analytics/analytics.dart';
import 'package:checkers_app/core/analytics/analytics_event.dart';

/// Drops every event. Bound in `app/di/modules/core_module.dart`;
/// replace the binding there with a real backend adapter.
class NoopAnalytics implements Analytics {
  const NoopAnalytics();

  @override
  Future<void> logEvent(AnalyticsEvent event) async {}

  @override
  Future<void> logScreenView(String screenName) async {}
}
