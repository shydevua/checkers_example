import 'package:checkers_app/core/analytics/analytics_event.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher _invalid(String argument, String value) => throwsA(
  isA<ArgumentError>()
      .having((e) => e.name, 'name', argument)
      .having((e) => e.invalidValue, 'value', value)
      .having((e) => e.message, 'message', 'is not a valid analytics name'),
);

void main() {
  test('valid name and parameters -> stored', () {
    final event = AnalyticsEvent('game_started', const {'difficulty': 'easy'});
    expect(event.name, 'game_started');
    expect(event.parameters, {'difficulty': 'easy'});
  });

  test('no parameters -> empty map', () {
    expect(AnalyticsEvent('x').parameters, isEmpty);
  });

  test('parameters are an unmodifiable copy', () {
    final source = <String, Object>{'a': 1};
    final event = AnalyticsEvent('x', source);
    source['b'] = 2;
    expect(event.parameters, {'a': 1});
    expect(() => event.parameters['c'] = 3, throwsUnsupportedError);
  });

  test('40-character name -> valid; 41 -> ArgumentError', () {
    expect(AnalyticsEvent('a' * 40).name, hasLength(40));
    expect(() => AnalyticsEvent('a' * 41), _invalid('name', 'a' * 41));
  });

  test('empty name -> ArgumentError', () {
    expect(() => AnalyticsEvent(''), _invalid('name', ''));
  });

  test('name starting with a digit or underscore -> ArgumentError', () {
    expect(() => AnalyticsEvent('1st'), _invalid('name', '1st'));
    expect(() => AnalyticsEvent('_x'), _invalid('name', '_x'));
  });

  test('name with other characters -> ArgumentError', () {
    expect(() => AnalyticsEvent('game-over'), _invalid('name', 'game-over'));
  });

  test('digits and underscores after the first letter -> valid', () {
    expect(AnalyticsEvent('Level_2').name, 'Level_2');
  });

  test('bad parameter key -> ArgumentError', () {
    expect(
      () => AnalyticsEvent('x', const {'bad key': 1}),
      _invalid('parameters', 'bad key'),
    );
  });

  test('equality by name and parameters', () {
    expect(
      AnalyticsEvent('x', const {'a': 1}),
      AnalyticsEvent('x', const {'a': 1}),
    );
    expect(
      AnalyticsEvent('x', const {'a': 1}),
      isNot(AnalyticsEvent('x', const {'a': 2})),
    );
    expect(AnalyticsEvent('x'), isNot(AnalyticsEvent('y')));
  });
}
