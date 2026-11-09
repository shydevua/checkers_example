import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:equatable/equatable.dart';

sealed class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

final class StatsInitial extends StatsState {
  const StatsInitial();
}

final class StatsLoadInProgress extends StatsState {
  const StatsLoadInProgress();
}

final class StatsLoaded extends StatsState {
  const StatsLoaded(this.stats);

  final GameStats stats;

  @override
  List<Object?> get props => [stats];
}

final class StatsFailure extends StatsState {
  const StatsFailure(this.exception);

  final StatsException exception;

  @override
  List<Object?> get props => [exception];
}
