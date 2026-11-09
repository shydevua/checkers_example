import 'package:checkers_app/core/analytics/analytics_event.dart';
import 'package:checkers_app/features/game/domain/game_domain.dart';
import 'package:checkers_app/features/game/presentation/analytics/game_analytics.dart';
import 'package:checkers_app/features/shared/game_results/difficulty.dart';
import 'package:checkers_app/features/shared/game_results/game_outcome.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('started -> game_started with the level name', () {
    expect(
      GameAnalytics.started(Difficulty.hard, PieceColor.black),
      AnalyticsEvent('game_started', const {
        'difficulty': 'hard',
        'color': 'black',
      }),
    );
  });

  test('undone -> move_undone with the level', () {
    expect(
      GameAnalytics.undone(Difficulty.easy),
      AnalyticsEvent('move_undone', const {'difficulty': 'easy'}),
    );
  });

  test('finished -> game_finished with level and outcome', () {
    expect(
      GameAnalytics.finished(Difficulty.medium, GameOutcome.draw),
      AnalyticsEvent('game_finished', const {
        'difficulty': 'medium',
        'outcome': 'draw',
      }),
    );
  });
}
