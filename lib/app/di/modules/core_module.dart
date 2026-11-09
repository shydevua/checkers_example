import 'package:checkers_app/core/analytics/analytics.dart';
import 'package:checkers_app/core/analytics/noop_analytics.dart';
import 'package:checkers_app/core/analytics/track_event.dart';
import 'package:checkers_app/core/monitoring/error_reporter.dart';
import 'package:checkers_app/core/monitoring/noop_error_reporter.dart';
import 'package:checkers_app/core/storage/key_value_storage.dart';
import 'package:checkers_app/core/storage/shared_preferences_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared infrastructure and ports.
///
/// To plug in a real analytics or error-monitoring product, bind its adapter
/// here instead of the no-op one (optionally per environment with `@prod`).
@module
abstract class CoreModule {
  @lazySingleton
  SharedPreferencesAsync get sharedPreferences => SharedPreferencesAsync();

  @lazySingleton
  KeyValueStorage storage(SharedPreferencesAsync preferences) =>
      SharedPreferencesStorage(preferences);

  @lazySingleton
  Analytics get analytics => const NoopAnalytics();

  @lazySingleton
  ErrorReporter get errorReporter => const NoopErrorReporter();

  @lazySingleton
  TrackEvent trackEvent(Analytics analytics) => TrackEvent(analytics);
}
