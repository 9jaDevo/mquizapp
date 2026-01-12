import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

/// AdConsentTracker logs user consent/rejection for audit trail
/// Used in rewarded_ad_cubit.dart and rewarded_interstitial_ad_cubit.dart
class AdConsentTracker {
  static const String _consentKey = 'ad_consent_count_';
  static const String _rejectionKey = 'ad_rejection_count_';

  /// Record when user consents to watch ad
  static Future<void> recordConsent(String placementId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _consentKey + placementId;
      
      final currentCount = prefs.getInt(key) ?? 0;
      await prefs.setInt(key, currentCount + 1);
      
      log('Ad consent recorded for $placementId (total: ${currentCount + 1})', 
          name: 'AdConsent');
    } catch (e) {
      log('Error recording consent: $e', name: 'AdConsent');
    }
  }

  /// Record when user rejects/skips ad
  static Future<void> recordRejection(String placementId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _rejectionKey + placementId;
      
      final currentCount = prefs.getInt(key) ?? 0;
      await prefs.setInt(key, currentCount + 1);
      
      log('Ad rejection recorded for $placementId (total: ${currentCount + 1})', 
          name: 'AdConsent');
    } catch (e) {
      log('Error recording rejection: $e', name: 'AdConsent');
    }
  }

  /// Get consent statistics for a placement
  static Future<Map<String, int>> getStats(String placementId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final consents = prefs.getInt(_consentKey + placementId) ?? 0;
      final rejections = prefs.getInt(_rejectionKey + placementId) ?? 0;
      
      return {
        'consent': consents,
        'rejection': rejections,
        'total': consents + rejections,
      };
    } catch (e) {
      log('Error getting stats: $e', name: 'AdConsent');
      return {'consent': 0, 'rejection': 0, 'total': 0};
    }
  }
}
