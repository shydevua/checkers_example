import 'package:equatable/equatable.dart';

/// A single business operation that completes once.
// The contract every use case implements; mocked in tests.
// ignore: one_member_abstracts
abstract interface class UseCase<T, P> {
  Future<T> call(P params);
}

/// A single business operation that emits many values.
// ignore: one_member_abstracts
abstract interface class StreamUseCase<T, P> {
  Stream<T> call(P params);
}

/// Parameters of a use case that needs none.
final class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
