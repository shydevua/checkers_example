import 'package:checkers_app/core/analytics/analytics.dart';
import 'package:checkers_app/core/analytics/analytics_event.dart';
import 'package:checkers_app/core/usecases/use_case.dart';

/// Sends a product analytics event. Never throws.
class TrackEvent implements UseCase<void, AnalyticsEvent> {
  const TrackEvent(this._analytics);

  final Analytics _analytics;

  @override
  Future<void> call(AnalyticsEvent params) => _analytics.logEvent(params);
}
