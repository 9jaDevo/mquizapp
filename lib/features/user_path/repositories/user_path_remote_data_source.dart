import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/core/constants/api_exception.dart';
import 'package:flutterquiz/core/constants/constants.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:http/http.dart' as http;

final class UserPathRemoteDataSource {
  /// Set user's learning path
  Future<Map<String, dynamic>> setUserPath({
    required String selectedPath,
    String? topicsPreference,
    int? dailyGoalMinutes,
    bool? demoQuizCompleted,
  }) async {
    try {
      final body = <String, String>{
        'selected_path': selectedPath,
        if (topicsPreference != null) 'topics_preference': topicsPreference,
        if (dailyGoalMinutes != null)
          'daily_goal_minutes': dailyGoalMinutes.toString(),
        if (demoQuizCompleted != null)
          'demo_quiz_completed': demoQuizCompleted ? '1' : '0',
      };

      final response = await http.post(
        Uri.parse('$baseUrl/Api/set_user_path'),
        headers: await ApiUtils.getHeaders(),
        body: body,
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ApiException(responseJson['message'].toString());
      }

      return responseJson['data'] as Map<String, dynamic>;
    } on SocketException {
      throw const ApiException(errorCodeNoInternet);
    } on ApiException {
      rethrow;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Get user's current learning path
  Future<Map<String, dynamic>?> getUserPath() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Api/get_user_path'),
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        // If no path is set, return null instead of throwing
        if (responseJson['message'].toString().toLowerCase().contains('no path')) {
          return null;
        }
        throw ApiException(responseJson['message'].toString());
      }

      return responseJson['data'] as Map<String, dynamic>?;
    } on SocketException {
      throw const ApiException(errorCodeNoInternet);
    } on ApiException {
      rethrow;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Switch user's learning path
  Future<Map<String, dynamic>> switchUserPath({
    required String newPath,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/Api/switch_user_path'),
        headers: await ApiUtils.getHeaders(),
        body: {'new_path': newPath},
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ApiException(responseJson['message'].toString());
      }

      return responseJson['data'] as Map<String, dynamic>;
    } on SocketException {
      throw const ApiException(errorCodeNoInternet);
    } on ApiException {
      rethrow;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Get personalized content based on user's path
  Future<Map<String, dynamic>> getPersonalizedContent({
    int? limit,
  }) async {
    try {
      final body = <String, String>{};
      if (limit != null) {
        body['limit'] = limit.toString();
      }

      final response = await http.post(
        Uri.parse('$baseUrl/Api/get_personalized_content'),
        headers: await ApiUtils.getHeaders(),
        body: body,
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ApiException(responseJson['message'].toString());
      }

      return responseJson['data'] as Map<String, dynamic>;
    } on SocketException {
      throw const ApiException(errorCodeNoInternet);
    } on ApiException {
      rethrow;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }

  /// Get categories filtered by audience
  Future<List<dynamic>> getCategoriesByAudience({
    String audience = 'general',
    String? languageId,
  }) async {
    try {
      final body = <String, String>{
        'audience': audience,
        if (languageId != null) 'language_id': languageId,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/Api/get_categories_by_audience'),
        headers: await ApiUtils.getHeaders(),
        body: body,
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ApiException(responseJson['message'].toString());
      }

      return responseJson['data'] as List<dynamic>;
    } on SocketException {
      throw const ApiException(errorCodeNoInternet);
    } on ApiException {
      rethrow;
    } on Exception catch (e) {
      throw ApiException(e.toString());
    }
  }
}
