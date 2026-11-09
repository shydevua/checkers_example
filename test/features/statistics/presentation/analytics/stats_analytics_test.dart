import 'package:checkers_app/core/analytics/analytics_event.dart';
import 'package:checkers_app/features/statistics/presentation/analytics/stats_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reset -> stats_reset', () {
    expect(StatsAnalytics.reset(), AnalyticsEvent('stats_reset'));
  });
}
