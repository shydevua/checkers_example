import 'package:checkers_app/core/monitoring/error_reporter.dart';
import 'package:checkers_app/core/monitoring/noop_error_reporter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('accepts everything and completes', () async {
    const reporter = NoopErrorReporter();
    expect(reporter, isA<ErrorReporter>());
    await expectLater(
      reporter.recordError(StateError('x'), StackTrace.current, fatal: true),
      completes,
    );
    await expectLater(reporter.log('breadcrumb'), completes);
  });
}
