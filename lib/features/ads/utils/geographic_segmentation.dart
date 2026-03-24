import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

/// Geographic regions for ad segmentation
enum AdRegion {
  eu, // European Union - strict GDPR requirements
  california, // California - CCPA requirements
  other, // Rest of world - standard requirements
}

/// GeographicSegmentation manages user location-based ad policies
/// Different regions have different regulations (GDPR, CCPA, etc)
class GeographicSegmentation {
  static const String _regionKey = 'ad_region_';
  static const String _consentKey = 'ad_consent_';
  static const String _lastCheckKey = 'ad_region_check_';

  // EU countries list (ISO 3166-1 alpha-2 codes)
  static const List<String> _euCountries = [
    'AT', 'BE', 'BG', 'HR', 'CY', 'CZ', 'DK', 'EE', 'FI', 'FR',
    'DE', 'GR', 'HU', 'IE', 'IT', 'LV', 'LT', 'LU', 'MT', 'NL',
    'PL', 'PT', 'RO', 'SK', 'SI', 'ES', 'SE', 'GB', // GB included for GDPR
  ];

  // California state code variants (if upstream provides subdivision value)
  static const String _californiaCode = 'US-CA';

  /// Detect user's region based on country code
  static AdRegion detectRegion(String? countryCode) {
    if (countryCode == null) return AdRegion.other;

    final upperCode = countryCode.toUpperCase();

    if (_euCountries.contains(upperCode)) {
      return AdRegion.eu;
    }

    if (upperCode == _californiaCode || upperCode == 'US_CA') {
      // Only classify as California when subdivision-level code is available.
      return AdRegion.california;
    }

    return AdRegion.other;
  }

  /// Get or cache user's region
  static Future<AdRegion> getUserRegion({String? countryCode}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Return cached region if still valid (24 hour cache)
      final lastCheck = prefs.getInt(_lastCheckKey);
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;

      if (lastCheck != null && (now - lastCheck) < 86400000) {
        // Cache still valid
        final regionStr = prefs.getString(_regionKey);
        if (regionStr != null) {
          return AdRegion.values.firstWhere(
            (e) => e.toString() == regionStr,
            orElse: () => AdRegion.other,
          );
        }
      }

      // Detect region (in real app, use device locale or IP lookup)
      final region = detectRegion(countryCode);

      // Cache the region
      await prefs.setString(_regionKey, region.toString());
      await prefs.setInt(_lastCheckKey, now);

      log('User region set to: ${region.name}', name: 'Geographic');

      return region;
    } catch (e) {
      log('Error getting user region: $e', name: 'Geographic');
      return AdRegion.other;
    }
  }

  /// Check if user is in EU (GDPR applies)
  static Future<bool> isEUUser() async {
    final region = await getUserRegion();
    return region == AdRegion.eu;
  }

  /// Check if user is in California (CCPA applies)
  static Future<bool> isCaliforniaUser() async {
    final region = await getUserRegion();
    return region == AdRegion.california;
  }

  /// Record explicit consent for ads (for GDPR compliance)
  static Future<void> recordAdConsent(bool hasConsented) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_consentKey, hasConsented);

      final region = await getUserRegion();
      log(
        'Ad consent recorded: $hasConsented (region: ${region.name})',
        name: 'Geographic',
      );
    } catch (e) {
      log('Error recording consent: $e', name: 'Geographic');
    }
  }

  /// Check if user has given explicit consent (for GDPR users)
  static Future<bool> hasGivenConsent() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final region = await getUserRegion();

      // EU users must have explicit consent
      if (region == AdRegion.eu) {
        final consent = prefs.getBool(_consentKey);
        return consent ?? false;
      }

      // Others don't require explicit consent by default
      return true;
    } catch (e) {
      log('Error checking consent: $e', name: 'Geographic');
      return false;
    }
  }

  /// Get ad frequency limits based on region
  /// EU users should see fewer ads due to GDPR sensitivity
  /// Phase 4: Boosted non-EU limits to maximize monetization
  static Future<AdFrequencyLimits> getFrequencyLimits() async {
    try {
      final region = await getUserRegion();

      switch (region) {
        case AdRegion.eu:
          // Strict limits for EU (GDPR)
          return AdFrequencyLimits(
            minInterstitialGapMs: 120000, // 2 minutes
            maxInterstitialsPerDay: 3,
            minRewardedGapMs: 180000, // 3 minutes
            maxRewardedPerDay: 3,
          );

        case AdRegion.california:
          // CCPA - stricter than global baseline
          return AdFrequencyLimits(
            minInterstitialGapMs: 90000, // 90 seconds
            maxInterstitialsPerDay: 4,
            minRewardedGapMs: 120000, // 2 minutes
            maxRewardedPerDay: 5,
          );

        case AdRegion.other:
          // Phase 4: Boosted aggressive limits for rest of world
          // (Nepal, Nigeria, Kenya, India, Ghana, etc.)
          return AdFrequencyLimits(
            minInterstitialGapMs: 30000, // 30 seconds (down from 60s)
            maxInterstitialsPerDay: 12, // Up from 5
            minRewardedGapMs: 45000, // 45 seconds (down from 60s)
            maxRewardedPerDay: 20, // Up from 10
          );
      }
    } catch (e) {
      log('Error getting frequency limits: $e', name: 'Geographic');
      // Return safe defaults
      return AdFrequencyLimits(
        minInterstitialGapMs: 120000,
        maxInterstitialsPerDay: 3,
        minRewardedGapMs: 180000,
        maxRewardedPerDay: 3,
      );
    }
  }

  /// Clear cached region (useful for testing)
  static Future<void> clearCachedRegion() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_regionKey);
      await prefs.remove(_lastCheckKey);
      log('Cached region cleared', name: 'Geographic');
    } catch (e) {
      log('Error clearing cached region: $e', name: 'Geographic');
    }
  }
}

/// Ad frequency limits that vary by region
class AdFrequencyLimits {
  final int minInterstitialGapMs;
  final int maxInterstitialsPerDay;
  final int minRewardedGapMs;
  final int maxRewardedPerDay;

  AdFrequencyLimits({
    required this.minInterstitialGapMs,
    required this.maxInterstitialsPerDay,
    required this.minRewardedGapMs,
    required this.maxRewardedPerDay,
  });

  @override
  String toString() =>
      '''
AdFrequencyLimits(
  interstitial: gap=${minInterstitialGapMs}ms, max=$maxInterstitialsPerDay/day,
  rewarded: gap=${minRewardedGapMs}ms, max=$maxRewardedPerDay/day
)''';
}
