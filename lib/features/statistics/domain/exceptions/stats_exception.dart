import 'package:checkers_app/core/exceptions/app_exception.dart';

/// Every exception the statistics feature can throw.
sealed class StatsException extends AppException {
  const StatsException();
}

/// Statistics could not be read from or written to storage.
final class StatsStorageException extends StatsException {
  const StatsStorageException();
}

/// Stored statistics exist but cannot be understood.
final class StatsCorruptedException extends StatsException {
  const StatsCorruptedException();
}
