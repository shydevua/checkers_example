import 'package:checkers_app/core/analytics/analytics_event.dart';

/// Product events of the statistics feature.
abstract final class StatsAnalytics {
  static AnalyticsEvent reset() => AnalyticsEvent('stats_reset');
}
