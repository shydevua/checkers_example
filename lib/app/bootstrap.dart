import 'package:checkers_app/app/app.dart';
import 'package:checkers_app/app/di/environment.dart';
import 'package:checkers_app/app/di/injection.dart';
import 'package:checkers_app/app/observers/app_bloc_observer.dart';
import 'package:checkers_app/app/observers/error_handlers.dart';
import 'package:checkers_app/core/analytics/analytics.dart';
import 'package:checkers_app/core/monitoring/error_reporter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Starts the app. Error handlers go first, so nothing that fails during
/// start-up escapes monitoring.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  installErrorHandlers(
    () => getIt.isRegistered<ErrorReporter>() ? getIt<ErrorReporter>() : null,
  );
  await configureDependencies(parseEnvironment(rawEnvironment));
  Bloc.observer = AppBlocObserver(getIt<ErrorReporter>());
  runApp(App(analytics: getIt<Analytics>()));
}
