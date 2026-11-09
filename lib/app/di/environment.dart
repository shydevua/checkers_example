import 'package:injectable/injectable.dart';

/// Name passed with `--dart-define=ENV=...`; `dev` when omitted.
const String rawEnvironment = String.fromEnvironment(
  'ENV',
  defaultValue: Environment.dev,
);

/// The DI environment for [raw].
///
/// Throws [ArgumentError] for an unknown name: a misconfigured build must
/// fail at start, not silently run with the wrong bindings.
String parseEnvironment(String raw) => switch (raw) {
  Environment.dev || Environment.prod => raw,
  _ => throw ArgumentError.value(raw, 'ENV', 'must be "dev" or "prod"'),
};
