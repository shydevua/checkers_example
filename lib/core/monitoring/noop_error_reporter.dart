import 'package:checkers_app/core/monitoring/error_reporter.dart';

/// Drops every report. Bound in `app/di/modules/core_module.dart`;
/// replace the binding there with a real backend adapter.
class NoopErrorReporter implements ErrorReporter {
  const NoopErrorReporter();

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
  }) async {}

  @override
  Future<void> log(String message) async {}
}
