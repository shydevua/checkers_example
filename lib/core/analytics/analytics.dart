import 'package:checkers_app/core/analytics/analytics_event.dart';

/// Port to a product analytics backend (Firebase Analytics, Amplitude...).
///
/// Implementations never throw: analytics must not break the app. A failing
/// backend reports its own errors to the error reporter.
abstract interface class Analytics {
  Future<void> logEvent(AnalyticsEvent event);

  /// Name of the screen the user is looking at.
  Future<void> logScreenView(String screenName);
}
