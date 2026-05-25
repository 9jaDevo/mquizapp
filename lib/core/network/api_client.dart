/// Dio-based HTTP client for the NestJS API.
///
/// - Attaches a fresh Firebase ID token before every request.
/// - On 401: refreshes the token once and retries automatically.
/// - Throws [ApiClientException] for all error cases.
/// - All response bodies go through [ApiResponse] envelope parsing.
library;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutterquiz/core/network/api_client_exception.dart';
import 'package:flutterquiz/core/network/api_config.dart';
import 'package:flutterquiz/core/network/api_response.dart';

/// Singleton Dio client pre-configured for the NestJS API.
class ApiClient {
  ApiClient._();

  static final ApiClient _instance = ApiClient._();
  static ApiClient get instance => _instance;

  late final Dio _dio = _buildDio();

  Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: apiRoot,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
      ),
    );

    // Auth interceptor — attach Firebase ID token to every request
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _getFreshToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // On 401: refresh token once and retry
          if (error.response?.statusCode == 401) {
            try {
              final token = await _getFreshToken(forceRefresh: true);
              if (token != null) {
                final retried = await _retry(error.requestOptions, token);
                return handler.resolve(retried);
              }
            } catch (_) {
              // fall through to error handler
            }
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        request: true,
        responseBody: true,
        error: true,
        requestHeader: false, // don't log auth tokens
      ));
    }

    return dio;
  }

  Future<String?> _getFreshToken({bool forceRefresh = false}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      return await user.getIdToken(forceRefresh);
    } catch (_) {
      return null;
    }
  }

  Future<Response<dynamic>> _retry(
    RequestOptions options,
    String token,
  ) async {
    options.headers['Authorization'] = 'Bearer $token';
    return _dio.fetch(options);
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// GET [path] and return parsed [ApiResponse<T>].
  Future<ApiResponse<T>> get<T>(
    String path,
    T Function(dynamic) fromJson, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(res.data!, fromJson);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// POST [path] with [body] and return parsed [ApiResponse<T>].
  Future<ApiResponse<T>> post<T>(
    String path,
    T Function(dynamic) fromJson, {
    dynamic body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        path,
        data: body,
        queryParameters: queryParameters,
      );
      return ApiResponse.fromJson(res.data!, fromJson);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// PUT [path] with [body] and return parsed [ApiResponse<T>].
  Future<ApiResponse<T>> put<T>(
    String path,
    T Function(dynamic) fromJson, {
    dynamic body,
  }) async {
    try {
      final res = await _dio.put<Map<String, dynamic>>(path, data: body);
      return ApiResponse.fromJson(res.data!, fromJson);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  /// DELETE [path] and return parsed [ApiResponse<T>].
  Future<ApiResponse<T>> delete<T>(
    String path,
    T Function(dynamic) fromJson,
  ) async {
    try {
      final res = await _dio.delete<Map<String, dynamic>>(path);
      return ApiResponse.fromJson(res.data!, fromJson);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  // ── Error mapping ──────────────────────────────────────────────────────────

  ApiClientException _mapError(DioException e) {
    if (e.response != null) {
      final data = e.response!.data;
      String message = 'Request failed';
      String? errorCode;
      if (data is Map<String, dynamic>) {
        message = data['message']?.toString() ?? message;
        errorCode = data['error']?.toString();
      }
      return ApiClientException(
        message: message,
        statusCode: e.response!.statusCode,
        errorCode: errorCode,
      );
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return const ApiClientException(message: 'Connection timed out');
    }
    if (e.type == DioExceptionType.connectionError) {
      return const ApiClientException(message: 'No internet connection');
    }
    return ApiClientException(message: e.message ?? 'Network error');
  }
}
