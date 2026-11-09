import 'package:equatable/equatable.dart';

/// Infrastructure exception: the key-value storage could not be accessed.
///
/// It never leaves the data layer: repositories translate it into their
/// feature's domain exception.
final class StorageException extends Equatable implements Exception {
  const StorageException(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
