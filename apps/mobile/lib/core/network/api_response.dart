/// Generic wrapper for NestJS response envelope:
/// { "success": true,  "data": T,     "message": "OK" }
/// { "success": false, "error": "CODE", "message": "reason" }
library;

import 'package:mquiz/core/network/api_client_exception.dart';

class ApiResponse<T> {
  const ApiResponse._({
    required this.success,
    required this.data,
    required this.message,
    this.errorCode,
  });

  final bool success;
  final T? data;
  final String message;
  final String? errorCode;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic data) fromJson,
  ) {
    final success = json['success'] as bool? ?? false;
    if (!success) {
      throw ApiClientException(
        message: json['message']?.toString() ?? 'Unknown error',
        errorCode: json['error']?.toString(),
      );
    }
    return ApiResponse._(
      success: true,
      data: json['data'] != null ? fromJson(json['data']) : null,
      message: json['message']?.toString() ?? 'OK',
    );
  }

  /// Convenience: parse a list response where `data` is a JSON array.
  static ApiResponse<List<T>> fromJsonList<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    return ApiResponse.fromJson(json, (data) {
      if (data is List) {
        return data.whereType<Map<String, dynamic>>().map(itemFromJson).toList();
      }
      return <T>[];
    });
  }
}
