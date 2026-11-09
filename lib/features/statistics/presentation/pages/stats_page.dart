import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/widgets/app_page_layout.dart';
import 'package:checkers_app/features/statistics/presentation/pages/widgets/stats_body.dart';
import 'package:checkers_app/features/statistics/presentation/pages/widgets/stats_reset_button.dart';
import 'package:flutter/material.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppPageLayout(
      title: l10n.statistics,
      actions: const [StatsResetButton()],
      body: const StatsBody(),
    );
  }
}
