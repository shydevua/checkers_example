import 'package:checkers_app/core/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';

export 'package:checkers_app/core/l10n/generated/app_localizations.dart';

/// Short access to the generated strings: `context.l10n.appTitle`.
///
/// Strings live in `lib/core/l10n/arb/app_<language>.arb` and are compiled by
/// `flutter gen-l10n` (also run by `flutter pub get` / `flutter run`).
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
