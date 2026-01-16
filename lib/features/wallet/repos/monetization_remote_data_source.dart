import 'dart:convert';
import 'dart:io';

import 'package:flutterquiz/core/constants/api_exception.dart';
import 'package:flutterquiz/core/constants/constants.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:http/http.dart' as http;

/// Remote data source for monetization features (Phase 3)
/// Handles daily streaks, device registration, fraud detection, payout eligibility,
/// sponsor banners, boost earnings, and other engagement features
final class MonetizationRemoteDataSource {
  const MonetizationRemoteDataSource();

  /// Check daily login streak and award coins
  /// Returns: {streak_count, coins_earned, bonus_unlocked, max_streak}
  Future<Map<String, dynamic>> checkDailyStreak() async {
    try {
      final response = await http.post(
        Uri.parse(checkDailyStreakUrl),
        headers: await ApiUtils.getHeaders(),
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
    } on Exception {
      throw const ApiException(errorCodeDefaultMessage);
    }
  }

  /// Register device to prevent multi-accounting and detect suspicious activity
  /// Parameters: device_id, device_type (android|ios), device_name
  /// Returns: {status, message, conflict_count}
  Future<Map<String, dynamic>> registerDevice({
    required String deviceId,
    required String deviceType,
    String? deviceName,
  }) async {
    try {
      final body = <String, String>{
        deviceIdKey: deviceId,
        deviceTypeKey: deviceType,
      };

      if (deviceName != null && deviceName.isNotEmpty) {
        body[deviceNameKey] = deviceName;
      }

      final response = await http.post(
        Uri.parse(registerDeviceUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
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
    } on Exception {
      throw const ApiException(errorCodeDefaultMessage);
    }
  }

  /// Evaluate user activity for fraud indicators
  /// Called after quiz completion, ad watch, or payout request
  /// Parameters: action_type (ad_watch|quiz_complete|payout_request), metadata (optional)
  /// Returns: {is_suspicious, detections[]}
  Future<Map<String, dynamic>> evaluateUserRisk({
    required String actionType,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final body = <String, String>{
        actionTypeKey: actionType,
      };

      if (metadata != null) {
        body[metadataKey] = jsonEncode(metadata);
      }

      final response = await http.post(
        Uri.parse(evaluateUserRiskUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
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
    } on Exception {
      throw const ApiException(errorCodeDefaultMessage);
    }
  }

  /// Check if user is eligible to withdraw/redeem coins
  /// Returns: {eligible, active_days, required_days, message}
  Future<Map<String, dynamic>> checkPayoutEligibility() async {
    try {
      final response = await http.post(
        Uri.parse(checkPayoutEligibilityUrl),
        headers: await ApiUtils.getHeaders(),
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
    } on Exception {
      throw const ApiException(errorCodeDefaultMessage);
    }
  }

  /// Get active sponsor banner for rotation display
  /// Returns: {banner_id, sponsor_name, title, image_url, redirect_url, impression_limit}
  /// No auth required - can be called before login
  Future<Map<String, dynamic>?> getSponsorBanner() async {
    try {
      final response = await http.post(
        Uri.parse(getSponsorBannerUrl),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        return null; // No active banner available
      }

      return responseJson['data'] as Map<String, dynamic>;
    } on SocketException {
      throw const ApiException(errorCodeNoInternet);
    } on ApiException {
      rethrow;
    } on Exception {
      throw const ApiException(errorCodeDefaultMessage);
    }
  }

  /// Log sponsor banner click for analytics
  /// Parameters: banner_id
  Future<void> recordSponsorBannerClick({
    required String bannerId,
  }) async {
    try {
      final body = <String, String>{
        bannerIdKey: bannerId,
      };

      final response = await http.post(
        Uri.parse(sponsorBannerClickUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
      );

      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;

      if (responseJson['error'] as bool) {
        throw ApiException(responseJson['message'].toString());
      }
    } on SocketException {
      throw const ApiException(errorCodeNoInternet);
    } on ApiException {
      rethrow;
    } on Exception {
      throw const ApiException(errorCodeDefaultMessage);
    }
  }

  /// Get boost earnings offer details (calculate doubled coins)
  /// Returns: {original_coins, boosted_coins, multiplier, coin_difference}
  Future<Map<String, dynamic>> offerBoostEarnings({
    required String coinsEarned,
  }) async {
    try {
      final body = <String, String>{
        coinsKey: coinsEarned,
      };

      final response = await http.post(
        Uri.parse(offerBoostEarningsUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
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
    } on Exception {
      throw const ApiException(errorCodeDefaultMessage);
    }
  }

  /// Apply boost earnings - credit boosted coins to user account
  /// Returns: {coins_awarded, updated_user_coins}
  Future<Map<String, dynamic>> applyBoostEarnings({
    required String boostedCoins,
  }) async {
    try {
      final body = <String, String>{
        coinsKey: boostedCoins,
      };

      final response = await http.post(
        Uri.parse(applyBoostEarningsUrl),
        body: body,
        headers: await ApiUtils.getHeaders(),
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
    } on Exception {
      throw const ApiException(errorCodeDefaultMessage);
    }
  }

  /// Get configuration for watch unlock premium feature
  /// Returns: {enabled, ad_count_required, message}
  /// No auth required - can be called before login
  Future<Map<String, dynamic>> getWatchUnlockConfig() async {
    try {
      final response = await http.post(
        Uri.parse(getWatchUnlockConfigUrl),
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
    } on Exception {
      throw const ApiException(errorCodeDefaultMessage);
    }
  }
}
