import 'package:equatable/equatable.dart';

/// A product analytics event. Names and parameter keys follow the strictest
/// common rules (Firebase): 1-40 characters, a letter first, then letters,
/// digits or underscores.
final class AnalyticsEvent extends Equatable {
  /// Throws [ArgumentError] if [name] or a parameter key breaks the naming
  /// rules: events are written by us, so a bad name is a programmer error.
  AnalyticsEvent(this.name, [Map<String, Object> parameters = const {}])
    : parameters = Map.unmodifiable(parameters) {
    _check(name, 'name');
    parameters.keys.forEach(_checkKey);
  }

  static final _pattern = RegExp(r'^[a-zA-Z][a-zA-Z0-9_]{0,39}$');

  final String name;
  final Map<String, Object> parameters;

  static void _checkKey(String key) => _check(key, 'parameters');

  static void _check(String value, String argument) {
    if (!_pattern.hasMatch(value)) {
      throw ArgumentError.value(
        value,
        argument,
        'is not a valid analytics name',
      );
    }
  }

  @override
  List<Object?> get props => [name, parameters];
}
