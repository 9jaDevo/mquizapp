/// Ad unit IDs for Google AdMob.
///
/// Architecture: Hybrid source-of-truth
///   1. Hardcoded production IDs are always the built-in fallback.
///   2. After loading backend settings, call [AdIds.applyRuntimeOverrides] to
///      prefer DB-configured IDs over the hardcoded ones. Invalid IDs (not
///      matching `ca-app-pub-`) are silently ignored to prevent revenue loss.
///
/// Test IDs (Google official) are used automatically in debug builds.
library;

import 'dart:io';
import 'package:flutter/foundation.dart';

abstract final class AdIds {
  AdIds._();

  static bool get _isTest => kDebugMode;

  // ── Android App ID (set in AndroidManifest.xml) ───────────────────────────
  // ca-app-pub-6905634678868103~2960521786

  // ── iOS App ID (set in Info.plist) ───────────────────────────────────────
  // ca-app-pub-6905634678868103~<ios-app-id>

  // ── Runtime override store ────────────────────────────────────────────────
  static final Map<String, String> _overrides = {};

  /// Apply remote ad unit IDs fetched from backend settings.
  ///
  /// Only well-formed IDs beginning with 'ca-app-pub-' and longer than 20
  /// characters are accepted. All others are silently skipped to prevent a
  /// bad backend config from breaking ad revenue.
  static void applyRuntimeOverrides(Map<String, String> settings) {
    _overrides.clear();
    int applied = 0;
    for (final entry in settings.entries) {
      if (_isValidAdUnitId(entry.value)) {
        _overrides[entry.key] = entry.value;
        applied++;
      } else if (kDebugMode) {
        debugPrint(
            '[AdIds] Skipped invalid override for ${entry.key}: "${entry.value}"');
      }
    }
    if (kDebugMode) {
      debugPrint('[AdIds] Applied $applied/${settings.length} overrides.');
    }
  }

  static bool _isValidAdUnitId(String id) =>
      id.startsWith('ca-app-pub-') && id.length > 20;

  /// Returns [testId] in debug, otherwise the backend override (if valid)
  /// or [productionId] as fallback.
  static String _resolve(
      String overrideKey, String productionId, String testId) {
    if (_isTest) return testId;
    return _overrides[overrideKey] ?? productionId;
  }

  // ── Rewarded ad ───────────────────────────────────────────────────────────
  static String get rewardedAdUnitId => Platform.isIOS
      ? _resolve(
          'ios_rewarded_id',
          'ca-app-pub-6905634678868103/4289081175',
          'ca-app-pub-3940256099942544/1712485313',
        )
      : _resolve(
          'android_rewarded_id',
          'ca-app-pub-6905634678868103/3495955824',
          'ca-app-pub-3940256099942544/5224354917',
        );

  // ── Interstitial ad ───────────────────────────────────────────────────────
  static String get interstitialAdUnitId => Platform.isIOS
      ? _resolve(
          'ios_interstitial_id',
          'ca-app-pub-6905634678868103/9630119330',
          'ca-app-pub-3940256099942544/4411468910',
        )
      : _resolve(
          'android_interstitial_id',
          'ca-app-pub-6905634678868103/8085937527',
          'ca-app-pub-3940256099942544/1033173712',
        );

  // ── App Open ad ───────────────────────────────────────────────────────────
  static String get appOpenAdUnitId => Platform.isIOS
      ? _resolve(
          'app_open_id_ios',
          'ca-app-pub-6905634678868103/8028615864',
          'ca-app-pub-3940256099942544/5575463023',
        )
      : _resolve(
          'app_open_id_android',
          'ca-app-pub-6905634678868103/2319309400',
          'ca-app-pub-3940256099942544/9257395921',
        );

  // ── Rewarded Interstitial ad ──────────────────────────────────────────────
  static String get rewardedInterstitialAdUnitId => Platform.isIOS
      ? _resolve(
          'rewarded_interstitial_id_ios',
          'ca-app-pub-6905634678868103/9886808230',
          'ca-app-pub-3940256099942544/6978759866',
        )
      : _resolve(
          'rewarded_interstitial_id_android',
          'ca-app-pub-6905634678868103/7210535827',
          'ca-app-pub-3940256099942544/5354046379',
        );

  // ── Banner ad (minimal placement — leaderboard / result screens only) ─────
  static String get bannerAdUnitId => Platform.isIOS
      ? _resolve(
          'ios_banner_id',
          'ca-app-pub-6905634678868103/7705194964',
          'ca-app-pub-3940256099942544/6300978111',
        )
      : _resolve(
          'android_banner_id',
          'ca-app-pub-6905634678868103/5602162844',
          'ca-app-pub-3940256099942544/6300978111',
        );
}
