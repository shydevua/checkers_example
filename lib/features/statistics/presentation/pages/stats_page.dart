import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/theme/app_spacing.dart';
import 'package:checkers_app/core/widgets/app_button.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_bloc.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_event.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_state.dart';
import 'package:checkers_app/features/statistics/presentation/widgets/stats_error_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatsPage extends StatelessWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics),
        actions: const [_ResetButton()],
      ),
      body: const SafeArea(child: _StatsBody()),
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton();

  @override
  Widget build(BuildContext context) {
    final enabled = context.select<StatsBloc, bool>(
      (bloc) => bloc.state is StatsLoaded,
    );
    return IconButton(
      key: const ValueKey('stats-reset'),
      tooltip: context.l10n.resetStatistics,
      icon: const Icon(Icons.delete_outline),
      onPressed: enabled
          ? () => context.read<StatsBloc>().add(const StatsResetRequested())
          : null,
    );
  }
}

class _StatsBody extends StatelessWidget {
  const _StatsBody();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StatsBloc>().state;
    return switch (state) {
      StatsInitial() || StatsLoadInProgress() => const Center(
        child: CircularProgressIndicator(),
      ),
      StatsLoaded(:final stats) => _StatsTable(stats: stats),
      StatsFailure(:final exception) => _StatsError(exception: exception),
    };
  }
}

class _StatsTable extends StatelessWidget {
  const _StatsTable({required this.stats});

  final GameStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final header = Theme.of(context).textTheme.titleSmall;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(2)},
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: [
          TableRow(
            children: [
              const SizedBox.shrink(),
              Text(l10n.wins, style: header),
              Text(l10n.losses, style: header),
              Text(l10n.draws, style: header),
            ],
          ),
          for (final difficulty in Difficulty.values)
            _row(l10n.difficulty(difficulty.name), stats, difficulty),
        ],
      ),
    );
  }

  static TableRow _row(String label, GameStats stats, Difficulty difficulty) {
    final level = stats.forDifficulty(difficulty);
    return TableRow(
      key: ValueKey('stats-${difficulty.name}'),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
          child: Text(label),
        ),
        Text('${level.wins}'),
        Text('${level.losses}'),
        Text('${level.draws}'),
      ],
    );
  }
}

class _StatsError extends StatelessWidget {
  const _StatsError({required this.exception});

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
