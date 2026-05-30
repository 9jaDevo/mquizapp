/// Singleton manager for Google AdMob rewarded and interstitial ads.
///
/// Security model:
/// - Rewarded ad: `onRewarded` callback is ONLY fired inside Google's
///   `onUserEarnedReward` — the server endpoint enforces the throttle and
///   max-lives check, so the client cannot fake a reward.
/// - Interstitial: non-blocking, shown after quiz completion at configurable
///   frequency. If not loaded, silently skipped — never blocks the user.
/// - Neither ad type blocks navigation or core game flow.
library;

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mquiz/core/ads/ad_ids.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  bool _rewardedLoading = false;
  bool _interstitialLoading = false;

  int _quizCompletions = 0;

  /// How many quiz completions between each interstitial. Default: 3.
  int adFrequency = 3;

  // Retry back-off state
  int _rewardedRetries = 0;
  int _interstitialRetries = 0;
  static const _maxRetries = 3;

  /// Call once in main() after [MobileAds.instance.initialize()].
  void initialize() {
    _loadRewarded();
    _loadInterstitial();
  }

  // ── Rewarded ──────────────────────────────────────────────────────────────

  void _loadRewarded() {
    if (_rewardedLoading || _rewardedAd != null) return;
    _rewardedLoading = true;
    RewardedAd.load(
      adUnitId: AdIds.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _rewardedLoading = false;
          _rewardedRetries = 0;
          if (kDebugMode) debugPrint('[AdService] Rewarded ad loaded.');
        },
        onAdFailedToLoad: (err) {
          _rewardedLoading = false;
          if (kDebugMode) {
            debugPrint('[AdService] Rewarded load failed: ${err.message}');
          }
          _scheduleRewardedRetry();
        },
      ),
    );
  }

  void _scheduleRewardedRetry() {
    if (_rewardedRetries >= _maxRetries) return;
    _rewardedRetries++;
    final delay = Duration(seconds: pow(2, _rewardedRetries).toInt());
    Timer(delay, _loadRewarded);
  }

  /// Shows the rewarded ad. Calls [onRewarded] ONLY inside Google's
  /// `onUserEarnedReward` callback — never preemptively.
  ///
  /// Returns `true` if the ad was displayed, `false` if not yet loaded.
  Future<bool> showRewardedAd({required VoidCallback onRewarded}) async {
    if (_rewardedAd == null) return false;

    final ad = _rewardedAd!;
    _rewardedAd = null; // mark consumed before show to avoid double-tap

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded(); // pre-load next ad
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _loadRewarded();
        if (kDebugMode) {
          debugPrint('[AdService] Rewarded show failed: ${err.message}');
        }
      },
    );

    await ad.show(
      onUserEarnedReward: (_, reward) {
        // This is the ONLY place onRewarded is called.
        onRewarded();
      },
    );
    return true;
  }

  // ── Interstitial ──────────────────────────────────────────────────────────

  void _loadInterstitial() {
    if (_interstitialLoading || _interstitialAd != null) return;
    _interstitialLoading = true;
    InterstitialAd.load(
      adUnitId: AdIds.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _interstitialLoading = false;
          _interstitialRetries = 0;
          if (kDebugMode) debugPrint('[AdService] Interstitial ad loaded.');
        },
        onAdFailedToLoad: (err) {
          _interstitialLoading = false;
          if (kDebugMode) {
            debugPrint('[AdService] Interstitial load failed: ${err.message}');
          }
          _scheduleInterstitialRetry();
        },
      ),
    );
  }

  void _scheduleInterstitialRetry() {
    if (_interstitialRetries >= _maxRetries) return;
    _interstitialRetries++;
    final delay = Duration(seconds: pow(2, _interstitialRetries).toInt());
    Timer(delay, _loadInterstitial);
  }

  /// Should be called after each quiz completion. Shows an interstitial every
  /// [adFrequency] completions if one is loaded; otherwise silently no-ops.
  void recordQuizCompletion() {
    _quizCompletions++;
    if (_quizCompletions % adFrequency == 0) {
      _showInterstitialIfReady();
    }
  }

  void _showInterstitialIfReady() {
    if (_interstitialAd == null) return;

    final ad = _interstitialAd!;
    _interstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _loadInterstitial();
      },
    );

    ad.show();
  }
}
