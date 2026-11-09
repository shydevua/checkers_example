import 'package:checkers_app/core/l10n/l10n.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_bloc.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_event.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatsResetButton extends StatelessWidget {
  const StatsResetButton({super.key});

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
