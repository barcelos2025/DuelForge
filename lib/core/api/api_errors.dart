class ApiException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  ApiException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'ApiException: $message (Code: $code)';
}

class NetworkException extends ApiException {
  NetworkException(String message, {dynamic originalError}) 
      : super(message, code: 'NETWORK_ERROR', originalError: originalError);
}

class ServerException extends ApiException {
  ServerException(String message, {String? code, dynamic originalError}) 
      : super(message, code: code, originalError: originalError);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message, code: 'VALIDATION_ERROR');
}
