import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/core/theme/app_spacing.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:flutter/material.dart';

class StatsTable extends StatelessWidget {
  const StatsTable({required this.stats, super.key});

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
