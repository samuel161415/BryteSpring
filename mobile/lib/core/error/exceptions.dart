import 'package:equatable/equatable.dart';

abstract class AppException extends Equatable implements Exception {
  final String message;
  final int? code;

  const AppException(this.message, [this.code]);

  @override
  List<Object?> get props => [message, code];
}

class ServerException extends AppException {
  const ServerException(String message, [int? code]) : super(message, code);
}

class CacheException extends AppException {
  const CacheException(String message) : super(message);
}

class NetworkException extends AppException {
  const NetworkException(String message) : super(message);
}

class ValidationException extends AppException {
  const ValidationException(String message) : super(message);
}

class PermissionException extends AppException {
  const PermissionException(String message) : super(message);
}
