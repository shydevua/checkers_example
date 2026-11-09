import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';

/// Exception -> user text. Exhaustive on purpose: a new exception type does
/// not compile until it has a message.
String statsErrorText(AppLocalizations l10n, StatsException e) => switch (e) {
  StatsStorageException() => l10n.statsStorageFailed,
  StatsCorruptedException() => l10n.statsCorrupted,
};
