abstract class AppException implements Exception {
  final String message;
  final int? statusCode;
  
  AppException(this.message, [this.statusCode]);

  @override
  String toString() => 'AppException: $message (Code: $statusCode)';
}

class NetworkException extends AppException {
  NetworkException(super.message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message, 401);
}

class BadRequestException extends AppException {
  BadRequestException(String message) : super(message, 400);
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, 404);
}

class ConflictException extends AppException {
  ConflictException(String message) : super(message, 409);
}

class ForbiddenException extends AppException {
  ForbiddenException(String message) : super(message, 403);
}

class ServerException extends AppException {
  ServerException(String message) : super(message, 500);
}