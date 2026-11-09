import 'package:checkers_app/app/di/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt getIt = GetIt.instance;

/// The only composition root: scans every `@module`, `@injectable` and
/// `@LazySingleton` in `lib/` (core, features).
@InjectableInit()
Future<void> configureDependencies(String environment) async =>
    getIt.init(environment: environment);
