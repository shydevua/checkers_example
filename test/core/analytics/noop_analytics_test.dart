import 'package:checkers_app/core/analytics/analytics.dart';
import 'package:checkers_app/core/analytics/analytics_event.dart';
import 'package:checkers_app/core/analytics/noop_analytics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts everything and completes', () async {
    const analytics = NoopAnalytics();
    expect(analytics, isA<Analytics>());
    await expectLater(analytics.logEvent(AnalyticsEvent('x')), completes);
    await expectLater(analytics.logScreenView('home'), completes);
  });
}
