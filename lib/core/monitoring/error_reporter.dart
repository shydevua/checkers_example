/// Port to an error monitoring backend (Crashlytics, Sentry...).
///
/// Implementations never throw: reporting must not cause new errors.
abstract interface class ErrorReporter {
  /// Records an error that escaped our code ([fatal]) or that we decided to
  /// report while recovering from it.
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
  });

  /// Adds a breadcrumb shown next to the following errors.
  Future<void> log(String message);
}
