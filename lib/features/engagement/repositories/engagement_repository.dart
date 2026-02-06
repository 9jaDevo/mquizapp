import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_endpoints_constants.dart';
import '../../../core/utils/api_utils.dart';

/// Repository for engagement-related API calls
class EngagementRepository {
  /// Get weekly engagement leaderboard
  ///
  /// [offset] - Pagination offset
  /// [limit] - Number of results to fetch
  /// [scope] - Filter scope: 'world', 'country', or 'region'
  /// [filterValue] - Country code or continent name based on scope
  Future<Map<String, dynamic>> getWeeklyEngagementLeaderboard({
    required String offset,
    required String limit,
    String scope = 'world',
    String? filterValue,
  }) async {
    try {
      final body = {
        'offset': offset,
        'limit': limit,
        'scope': scope,
      };

      if (filterValue != null && filterValue.isNotEmpty) {
        body['filter_value'] = filterValue;
      }

      final response = await http.post(
        Uri.parse(getWeeklyEngagementLeaderboardUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseJson;
      } else {
        throw EngagementException(
          errorMessageCode:
              responseJson['message'] ?? 'Failed to fetch leaderboard',
        );
      }
    } on SocketException catch (_) {
      throw EngagementException(errorMessageCode: 'No Internet connection');
    } on HttpException {
      throw EngagementException(errorMessageCode: 'HTTP error occurred');
    } on FormatException {
      throw EngagementException(errorMessageCode: 'Invalid response format');
    } catch (e) {
      throw EngagementException(errorMessageCode: e.toString());
    }
  }

  /// Get monthly engagement leaderboard
  Future<Map<String, dynamic>> getMonthlyEngagementLeaderboard({
    required String offset,
    required String limit,
    String scope = 'world',
    String? filterValue,
  }) async {
    try {
      final body = {
        'offset': offset,
        'limit': limit,
        'scope': scope,
      };

      if (filterValue != null && filterValue.isNotEmpty) {
        body['filter_value'] = filterValue;
      }

      final response = await http.post(
        Uri.parse(getMonthlyEngagementLeaderboardUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseJson;
      } else {
        throw EngagementException(
          errorMessageCode:
              responseJson['message'] ?? 'Failed to fetch leaderboard',
        );
      }
    } on SocketException catch (_) {
      throw EngagementException(errorMessageCode: 'No Internet connection');
    } on HttpException {
      throw EngagementException(errorMessageCode: 'HTTP error occurred');
    } on FormatException {
      throw EngagementException(errorMessageCode: 'Invalid response format');
    } catch (e) {
      throw EngagementException(errorMessageCode: e.toString());
    }
  }

  /// Get all-time engagement leaderboard
  Future<Map<String, dynamic>> getAllTimeEngagementLeaderboard({
    required String offset,
    required String limit,
    String scope = 'world',
    String? filterValue,
  }) async {
    try {
      final body = {
        'offset': offset,
        'limit': limit,
        'scope': scope,
      };

      if (filterValue != null && filterValue.isNotEmpty) {
        body['filter_value'] = filterValue;
      }

      final response = await http.post(
        Uri.parse(getAllTimeEngagementLeaderboardUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseJson;
      } else {
        throw EngagementException(
          errorMessageCode:
              responseJson['message'] ?? 'Failed to fetch leaderboard',
        );
      }
    } on SocketException catch (_) {
      throw EngagementException(errorMessageCode: 'No Internet connection');
    } on HttpException {
      throw EngagementException(errorMessageCode: 'HTTP error occurred');
    } on FormatException {
      throw EngagementException(errorMessageCode: 'Invalid response format');
    } catch (e) {
      throw EngagementException(errorMessageCode: e.toString());
    }
  }

  /// Update user's location
  Future<Map<String, dynamic>> updateUserLocation({
    required String countryCode,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(updateUserLocationUrl),
        body: {
          'country_code': countryCode,
        },
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseJson;
      } else {
        throw EngagementException(
          errorMessageCode:
              responseJson['message'] ?? 'Failed to update location',
        );
      }
    } on SocketException catch (_) {
      throw EngagementException(errorMessageCode: 'No Internet connection');
    } on HttpException {
      throw EngagementException(errorMessageCode: 'HTTP error occurred');
    } on FormatException {
      throw EngagementException(errorMessageCode: 'Invalid response format');
    } catch (e) {
      throw EngagementException(errorMessageCode: e.toString());
    }
  }
}

/// Custom exception for engagement-related errors
class EngagementException implements Exception {
  final String errorMessageCode;

  EngagementException({required this.errorMessageCode});

  @override
  String toString() => errorMessageCode;
}
