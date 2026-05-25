/// Typed exception thrown by [ApiClient] when the NestJS API returns an error
/// or the HTTP layer fails.
library;

class ApiClientException implements Exception {
  const ApiClientException({
    required this.message,
    this.statusCode,
    this.errorCode,
  });

  /// Human-readable message from the API or network layer.
  final String message;

  /// HTTP status code (null for network-level errors).
  final int? statusCode;

  /// Machine-readable error code from `{ "error": "ERROR_CODE" }` envelope.
  final String? errorCode;

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() => 'ApiClientException($statusCode, $errorCode): $message';
}
