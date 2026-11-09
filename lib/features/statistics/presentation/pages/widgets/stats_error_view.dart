import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/theme/app_spacing.dart';
import 'package:checkers_app/core/widgets/app_button.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_bloc.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_event.dart';
import 'package:checkers_app/features/statistics/presentation/pages/widgets/stats_error_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatsErrorView extends StatelessWidget {
  const StatsErrorView({required this.exception, super.key});

  final StatsException exception;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              statsErrorText(l10n, exception),
              key: const ValueKey('stats-error'),
            ),
            const SizedBox(height: AppSpacing.m),
            AppButton(
              key: const ValueKey('stats-retry'),
              label: l10n.retry,
              onPressed: () =>
                  context.read<StatsBloc>().add(const StatsRequested()),
            ),
          ],
        ),
      ),
    );
  }
}
