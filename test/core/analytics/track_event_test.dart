import 'package:checkers_app/core/analytics/analytics.dart';
import 'package:checkers_app/core/analytics/analytics_event.dart';
import 'package:checkers_app/core/analytics/track_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAnalytics extends Mock implements Analytics {}

void main() {
  test('sends the event to analytics', () async {
    final analytics = _MockAnalytics();
    final event = AnalyticsEvent('game_started');
    when(() => analytics.logEvent(event)).thenAnswer((_) async {});
    await TrackEvent(analytics)(event);
    verify(() => analytics.logEvent(event)).called(1);
    verifyNoMoreInteractions(analytics);
  });
}
