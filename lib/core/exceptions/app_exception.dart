import 'package:equatable/equatable.dart';

/// Base class of every typed exception thrown by our own code.
///
/// Subclasses are `const`, [Equatable] and named `...Exception`.
abstract class AppException extends Equatable implements Exception {
  const AppException();

  @override
  List<Object?> get props => [];
}
