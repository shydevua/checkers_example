import 'package:checkers_app/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Material theme of the app.
abstract final class AppTheme {
  static ThemeData light() => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.seed),
  );

  static ThemeData dark() => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.dark,
    ),
  );
}
