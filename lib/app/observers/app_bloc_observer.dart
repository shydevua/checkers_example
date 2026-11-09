import 'dart:async';

import 'package:checkers_app/core/monitoring/error_reporter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Reports errors that escaped a bloc: they are bugs, never user errors.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver(this._reporter);

  final ErrorReporter _reporter;

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    unawaited(
      _reporter.recordError(
        error,
        stackTrace,
        fatal: true,
        reason: 'Unhandled error in ${bloc.runtimeType}',
      ),
    );
    super.onError(bloc, error, stackTrace);
  }
}
