import 'dart:convert';

import 'package:flutterquiz/core/constants/constants.dart';
import 'package:flutterquiz/utils/api_utils.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Runtime flags for gradual ad-rollout control.
final class AdFeatureFlags {
  AdFeatureFlags._();

  static const String _prefix = 'ad_flag_';
  static const String utilityInterstitials = 'utility_interstitials';
  static const String walletBannerPlacement = 'wallet_banner_placement';
  static const String coinStoreBannerPlacement = 'coin_store_banner_placement';
  static const String rewardedFallback = 'rewarded_fallback';

  static final Map<String, bool> _defaults = <String, bool>{
    utilityInterstitials: true,
    walletBannerPlacement: true,
    coinStoreBannerPlacement: true,
    rewardedFallback: true,
  };

  static final Map<String, bool> _cache = <String, bool>{
    utilityInterstitials: true,
    walletBannerPlacement: true,
    coinStoreBannerPlacement: true,
    rewardedFallback: true,
  };

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _defaults.entries) {
      _cache[entry.key] = prefs.getBool('$_prefix${entry.key}') ?? entry.value;
    }
  }

  static bool isEnabled(String key) => _cache[key] ?? (_defaults[key] ?? false);

  static Future<void> set(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    _cache[key] = value;
    await prefs.setBool('$_prefix$key', value);
  }

  /// Pull rollout switches from backend when available.
  static Future<void> syncFromBackend() async {
    try {
      final response = await http.post(
        Uri.parse(getAdRolloutSettingsUrl),
        headers: await ApiUtils.getHeaders(),
      );

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['error'] == true || body['data'] is! Map<String, dynamic>) {
        return;
      }

      final data = body['data'] as Map<String, dynamic>;
      final mapping = <String, String>{
        'utility_interstitials': utilityInterstitials,
        'wallet_banner_placement': walletBannerPlacement,
        'coin_store_banner_placement': coinStoreBannerPlacement,
        'rewarded_fallback': rewardedFallback,
      };

      for (final entry in mapping.entries) {
        if (!data.containsKey(entry.key)) {
          continue;
        }
        final value = data[entry.key];
        final enabled = value.toString() == '1';
        await set(entry.value, enabled);
      }
    } catch (_) {
      // Fail-open: keep cached/local defaults if remote sync fails.
    }
  }
}
