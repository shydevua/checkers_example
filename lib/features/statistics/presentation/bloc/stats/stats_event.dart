import 'package:equatable/equatable.dart';

sealed class StatsEvent extends Equatable {
  const StatsEvent();

  @override
  List<Object?> get props => [];
}

final class StatsRequested extends StatsEvent {
  const StatsRequested();
}

final class StatsResetRequested extends StatsEvent {
  const StatsResetRequested();
}
