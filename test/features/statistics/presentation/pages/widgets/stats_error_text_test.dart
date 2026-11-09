import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:checkers_app/features/statistics/presentation/pages/widgets/stats_error_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final l10n = lookupAppLocalizations(const Locale('ru'));

  test('every statistics exception has its own text', () {
    expect(
      statsErrorText(l10n, const StatsStorageException()),
      l10n.statsStorageFailed,
    );
    expect(
      statsErrorText(l10n, const StatsCorruptedException()),
      l10n.statsCorrupted,
    );
  });
}
