import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:checkers_app/core/analytics/track_event.dart';
import 'package:checkers_app/core/usecases/use_case.dart';
import 'package:checkers_app/features/statistics/domain/statistics_domain.dart';
import 'package:checkers_app/features/statistics/presentation/analytics/stats_analytics.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_event.dart';
import 'package:checkers_app/features/statistics/presentation/bloc/stats/stats_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc(this._getGameStats, this._resetGameStats, this._trackEvent)
    : super(const StatsInitial()) {
    on<StatsRequested>(_onRequested, transformer: restartable());
    on<StatsResetRequested>(_onResetRequested, transformer: droppable());
  }

  final GetGameStats _getGameStats;
  final ResetGameStats _resetGameStats;
  final TrackEvent _trackEvent;

  Future<void> _onRequested(
    StatsRequested event,
    Emitter<StatsState> emit,
  ) async {
    emit(const StatsLoadInProgress());
    try {
      emit(StatsLoaded(await _getGameStats(const NoParams())));
    } on StatsException catch (e) {
      emit(StatsFailure(e));
    }
  }

  Future<void> _onResetRequested(
    StatsResetRequested event,
    Emitter<StatsState> emit,
  ) async {
    emit(const StatsLoadInProgress());
    try {
      emit(StatsLoaded(await _resetGameStats(const NoParams())));
      unawaited(_trackEvent(StatsAnalytics.reset()));
    } on StatsException catch (e) {
      emit(StatsFailure(e));
    }
  }
}
