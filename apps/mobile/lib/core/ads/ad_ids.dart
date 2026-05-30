/// Ad unit IDs for Google AdMob.
///
/// Test IDs are used in debug builds. Production IDs must be registered in
/// AdMob console before App Store / Play Store submission.
/// Replace every `REPLACE_*` placeholder with the real unit ID before release.
library;

import 'dart:io';
import 'package:flutter/foundation.dart';

abstract final class AdIds {
  AdIds._();

  static bool get _isTest => kDebugMode;

  // ── Android App ID (already in AndroidManifest.xml) ──────────────────────
  // ca-app-pub-6905634678868103~2960521786

  // ── iOS App ID (must be added to Info.plist before release) ──────────────
  // Replace the placeholder in Info.plist: ca-app-pub-REPLACE_WITH_IOS_ADMOB_APP_ID

  // ── Rewarded ad ───────────────────────────────────────────────────────────
  static String get rewardedAdUnitId {
    if (Platform.isIOS) {
      return _isTest
          ? 'ca-app-pub-3940256099942544/1712485313' // Google test ID (iOS rewarded)
          : 'ca-app-pub-REPLACE_WITH_IOS_REWARDED_AD_UNIT_ID';
    }
    return _isTest
        ? 'ca-app-pub-3940256099942544/5224354917' // Google test ID (Android rewarded)
        : 'ca-app-pub-6905634678868103/REPLACE_WITH_ANDROID_REWARDED_AD_UNIT_ID';
  }

  // ── Interstitial ad ───────────────────────────────────────────────────────
  static String get interstitialAdUnitId {
    if (Platform.isIOS) {
      return _isTest
          ? 'ca-app-pub-3940256099942544/4411468910' // Google test ID (iOS interstitial)
          : 'ca-app-pub-REPLACE_WITH_IOS_INTERSTITIAL_AD_UNIT_ID';
    }
    return _isTest
        ? 'ca-app-pub-3940256099942544/1033173712' // Google test ID (Android interstitial)
        : 'ca-app-pub-6905634678868103/REPLACE_WITH_ANDROID_INTERSTITIAL_AD_UNIT_ID';
  }
}
