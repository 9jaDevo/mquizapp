/// Typed exception thrown by [ApiClient] when the NestJS API returns an error
/// or the HTTP layer fails.
library;

class ApiClientException implements Exception {
  const ApiClientException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  final String message;
  final int? statusCode;
  final String? errorCode;

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isTooManyRequests => statusCode == 429;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() => 'ApiClientException($statusCode, $errorCode): $message';
}
