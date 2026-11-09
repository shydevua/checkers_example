import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_bloc.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_state.dart';
import 'package:checkers_app/features/statistics/presentation/pages/widgets/stats_error_view.dart';
import 'package:checkers_app/features/statistics/presentation/pages/widgets/stats_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatsBody extends StatelessWidget {
  const StatsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StatsBloc>().state;
    return switch (state) {
      StatsInitial() || StatsLoadInProgress() => const Center(
        child: CircularProgressIndicator(),
      ),
      StatsLoaded(:final stats) => StatsTable(stats: stats),
      StatsFailure(:final exception) => StatsErrorView(exception: exception),
    };
  }
}
