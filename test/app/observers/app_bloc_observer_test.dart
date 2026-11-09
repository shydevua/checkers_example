import 'package:checkers_app/app/observers/app_bloc_observer.dart';
import 'package:checkers_app/core/monitoring/error_reporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockErrorReporter extends Mock implements ErrorReporter {}

class _Cubit extends Cubit<int> {
  _Cubit() : super(0);
}

void main() {
  test('onError -> reported as fatal with the bloc type', () {
    final reporter = _MockErrorReporter();
    final error = StateError('bug');
    final stackTrace = StackTrace.current;
    when(
      () => reporter.recordError(
        error,
        stackTrace,
        fatal: true,
        reason: 'Unhandled error in _Cubit',
      ),
    ).thenAnswer((_) async {});
    final cubit = _Cubit();
    addTearDown(cubit.close);

    AppBlocObserver(reporter).onError(cubit, error, stackTrace);

    verify(
      () => reporter.recordError(
        error,
        stackTrace,
        fatal: true,
        reason: 'Unhandled error in _Cubit',
      ),
    ).called(1);
  });
}
