import 'package:checkers_app/app/observers/screen_view_observer.dart';
import 'package:checkers_app/core/analytics/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAnalytics extends Mock implements Analytics {}

Route<void> _route(String? name) => PageRouteBuilder<void>(
  settings: RouteSettings(name: name),
  pageBuilder: (_, _, _) => const SizedBox(),
);

void main() {
  late _MockAnalytics analytics;
  late ScreenViewObserver sut;

  setUp(() {
    analytics = _MockAnalytics();
    when(() => analytics.logScreenView(any())).thenAnswer((_) async {});
    sut = ScreenViewObserver(analytics);
  });

  test('push of a named route -> screen view', () {
    sut.didPush(_route('game'), _route('home'));
    verify(() => analytics.logScreenView('game')).called(1);
    verifyNoMoreInteractions(analytics);
  });

  test('pop -> the route below becomes the screen', () {
    sut.didPop(_route('game'), _route('home'));
    verify(() => analytics.logScreenView('home')).called(1);
    verifyNoMoreInteractions(analytics);
  });

  test('replace -> the new route', () {
    sut.didReplace(newRoute: _route('statistics'), oldRoute: _route('home'));
    verify(() => analytics.logScreenView('statistics')).called(1);
  });

  test('unnamed routes (dialogs) -> nothing', () {
    sut
      ..didPush(_route(null), _route('home'))
      ..didPop(_route('home'), null);
    verifyZeroInteractions(analytics);
  });
}
