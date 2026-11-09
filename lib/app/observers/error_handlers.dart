import 'dart:async';
import 'dart:developer' as developer;

import 'package:checkers_app/core/monitoring/error_reporter.dart';
import 'package:flutter/foundation.dart';

/// Installs the global error handlers — the only place allowed to catch
/// everything.
///
/// [reporter] is looked up when an error happens, so the handlers can be
/// installed before dependency injection: an error thrown while DI is being
/// configured is logged instead of lost.
void installErrorHandlers(ErrorReporter? Function() reporter) {
  void report(Object error, StackTrace stack, {String? reason}) {
    final target = reporter();
    if (target == null) {
      developer.log(
        reason ?? 'Uncaught error before start-up finished',
        name: 'app',
        error: error,
        stackTrace: stack,
      );
      return;
    }
    unawaited(target.recordError(error, stack, fatal: true, reason: reason));
  }

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    report(
      details.exception,
      details.stack ?? StackTrace.current,
      reason: details.context?.toDescription(),
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    report(error, stack);
    return true;
  };
}
