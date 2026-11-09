import 'dart:ui';

import 'package:checkers_app/app/observers/error_handlers.dart';
import 'package:checkers_app/core/monitoring/error_reporter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockErrorReporter extends Mock implements ErrorReporter {}

void main() {
  late FlutterExceptionHandler? flutterHandler;
  late ErrorCallback? platformHandler;
  late _MockErrorReporter reporter;
  final error = StateError('bug');
  final stack = StackTrace.current;

  setUp(() {
    flutterHandler = FlutterError.onError;
    platformHandler = PlatformDispatcher.instance.onError;
    reporter = _MockErrorReporter();
    when(
      () => reporter.recordError(
        error,
        stack,
        fatal: true,
        reason: any(named: 'reason'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() {
    FlutterError.onError = flutterHandler;
    PlatformDispatcher.instance.onError = platformHandler;
  });

  test('platform error -> reported as fatal and handled', () {
    installErrorHandlers(() => reporter);
    expect(PlatformDispatcher.instance.onError!(error, stack), isTrue);
    verify(() => reporter.recordError(error, stack, fatal: true)).called(1);
  });

  test('Flutter error -> reported as fatal with its context', () {
    installErrorHandlers(() => reporter);
    FlutterError.onError!(
      FlutterErrorDetails(
        exception: error,
        stack: stack,
        context: ErrorDescription('while testing'),
      ),
    );
    verify(
      () => reporter.recordError(
        error,
        stack,
        fatal: true,
        reason: 'while testing',
      ),
    ).called(1);
  });

  test('no reporter yet (DI not ready) -> handled, nothing lost', () {
    installErrorHandlers(() => null);
    expect(PlatformDispatcher.instance.onError!(error, stack), isTrue);
    verifyZeroInteractions(reporter);
  });

  test('reporter is looked up at error time, not at install time', () {
    ErrorReporter? current;
    installErrorHandlers(() => current);
    current = reporter;
    PlatformDispatcher.instance.onError!(error, stack);
    verify(() => reporter.recordError(error, stack, fatal: true)).called(1);
  });
}
