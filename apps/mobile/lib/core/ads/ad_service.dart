/// Singleton manager for all Google AdMob ad formats.
///
/// Supported formats (in revenue priority order):
///   1. Rewarded ($3.48 baseline)
///   2. Rewarded Interstitial ($1.57 — pilot rollout, max 1/session)
///   3. App-Open ($1.46 — shown on cold-start resume)
///   4. Interstitial ($1.86 — post-quiz, frequency-gated)
///   5. Banner (skipped in new app — low eCPM $0.13)
///
/// Security model:
/// - Rewarded: [onRewarded] callback fires ONLY inside Google's
///   `onUserEarnedReward`. Server endpoint enforces throttle and max-lives;
///   the client never grants reward preemptively.
/// - All formats: checked against [AdFrequencyManager] before show.
/// - Global kill-switch and per-format flags controlled via [configure].
///
/// Lifecycle:
///   main() → MobileAds.instance.initialize() → AdService.instance.initialize()
///   App resume → _onAppResumed() → try show app-open ad
library;

import 'dart:async';
import 'dart:math';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mquiz/core/ads/ad_frequency_manager.dart';
import 'package:mquiz/core/ads/ad_ids.dart';

/// Runtime configuration for [AdService].
///
/// Fetch from backend settings via the system-config API after login.
/// Call [AdService.instance.configure] with the loaded config.
class AdConfig {
  const AdConfig({
    this.adsEnabled = true,
    this.interstitialEnabled = true,
    this.rewardedEnabled = true,
    this.rewardedInterstitialEnabled = true,
    this.appOpenEnabled = true,
    this.interstitialFrequency = 3,
    this.limits = AdLimits.defaults,
  });

  /// Global master switch. When false, no ads are shown.
  final bool adsEnabled;
  final bool interstitialEnabled;
  final bool rewardedEnabled;
  final bool rewardedInterstitialEnabled;
  final bool appOpenEnabled;

  /// Show an interstitial every N quiz completions.
  final int interstitialFrequency;

  /// Per-format frequency limits (overrides [AdLimits.defaults]).
  final AdLimits limits;

  /// Build from a flat string map (e.g. from `tbl_settings` K/V API response).
  factory AdConfig.fromSettings(Map<String, String> settings) {
    int? tryInt(String key) => int.tryParse(settings[key] ?? '');
    bool flag(String key, {bool def = true}) =>
        settings[key] == null ? def : settings[key] == '1';

    return AdConfig(
      adsEnabled: flag('ads_enabled'),
      interstitialEnabled: flag('interstitial_enabled'),
      rewardedEnabled: flag('rewarded_enabled'),
      rewardedInterstitialEnabled:
          flag('rewarded_interstitial_enabled', def: false), // off by default
      appOpenEnabled: flag('app_open_enabled'),
      interstitialFrequency: tryInt('interstitial_frequency') ?? 3,
      limits: AdLimits.defaults.copyWith(
        interstitialMinGapMs: tryInt('interstitial_min_gap_ms'),
        interstitialMaxPerDay: tryInt('interstitial_max_per_day'),
        rewardedMinGapMs: tryInt('rewarded_min_gap_ms'),
        rewardedMaxPerDay: tryInt('rewarded_max_per_day'),
        rewardedMaxPerSession: tryInt('rewarded_max_per_session'),
        rewardedInterstitialMaxPerSession:
            tryInt('rewarded_interstitial_max_per_session'),
        appOpenMinGapMs: tryInt('app_open_min_gap_ms'),
        appOpenMaxPerDay: tryInt('app_open_max_per_day'),
      ),
    );
  }
}

class AdService with WidgetsBindingObserver {
  AdService._();
  static final AdService instance = AdService._();

  // ── State ─────────────────────────────────────────────────────────────────
  AdConfig _config = const AdConfig();
  bool _initialized = false;

  // Ad objects
  RewardedAd? _rewardedAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  InterstitialAd? _interstitialAd;
  AppOpenAd? _appOpenAd;

  // Load guards (prevent concurrent double-loads)
  bool _rewardedLoading = false;
  bool _rewardedInterstitialLoading = false;
  bool _interstitialLoading = false;
  bool _appOpenLoading = false;

  // App-open state
  bool _appOpenShowing = false;
  DateTime? _coldStartTime;

  // Interstitial trigger counter
  int _quizCompletions = 0;

  // Retry back-off
  int _rewardedRetries = 0;
  int _rewardedInterstitialRetries = 0;
  int _interstitialRetries = 0;
  int _appOpenRetries = 0;
  static const _maxRetries = 3;

  static const _tag = 'AdService';

  // ── Init ──────────────────────────────────────────────────────────────────

  /// Call once in main() after [MobileAds.instance.initialize()].
  /// Registers the lifecycle observer for app-open ads.
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _coldStartTime = DateTime.now();
    AdFrequencyManager.instance.startNewSession();

    WidgetsBinding.instance.addObserver(this);

    _loadRewarded();
    _loadInterstitial();
    _loadAppOpenAd();
    // Rewarded interstitial loaded lazily — only when feature flag is on.
  }

  /// Apply remote settings. Safe to call after every settings fetch.
  ///
  /// Also updates [AdIds] runtime overrides and [AdFrequencyManager] limits.
  void configure(AdConfig config, {Map<String, String>? adUnitOverrides}) {
    _config = config;
    AdFrequencyManager.instance.configure(config.limits);
    if (adUnitOverrides != null) {
      AdIds.applyRuntimeOverrides(adUnitOverrides);
    }
    // Start loading rewarded-interstitial if just enabled.
    if (config.rewardedInterstitialEnabled &&
        _rewardedInterstitialAd == null &&
        !_rewardedInterstitialLoading) {
      _loadRewardedInterstitial();
    }
  }

  /// Call on each explicit user logout / session end.
  void onSessionEnd() {
    AdFrequencyManager.instance.startNewSession();
    _quizCompletions = 0;
  }

  // ── WidgetsBindingObserver ────────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    }
  }

  Future<void> _onAppResumed() async {
    // Grace period: never show app-open on the very first cold-start resume.
    if (_coldStartTime != null) {
      final sinceStart = DateTime.now().difference(_coldStartTime!);
      if (sinceStart.inSeconds < 5) {
        _coldStartTime = null;
        return;
      }
      _coldStartTime = null;
    }

    await _showAppOpenIfReady();
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
          if (kDebugMode) debugPrint('[$_tag] Rewarded loaded.');
        },
        onAdFailedToLoad: (err) {
          _rewardedLoading = false;
          if (kDebugMode) {
            debugPrint('[$_tag] Rewarded load failed: ${err.message}');
          }
          _scheduleRetry(() => _loadRewarded(), _rewardedRetries++, 'rewarded');
        },
      ),
    );
  }

  /// Returns `true` if a rewarded ad is loaded AND the frequency cap allows it.
  Future<bool> isRewardedAdAvailable() async {
    if (_rewardedAd == null) return false;
    return AdFrequencyManager.instance.canShowRewarded();
  }

  /// Shows the rewarded ad. [onRewarded] fires ONLY inside Google's
  /// `onUserEarnedReward` — never preemptively.
  ///
  /// Returns `true` when the ad was displayed, `false` when not available or
  /// blocked by policy (caller should fall back gracefully).
  Future<bool> showRewardedAd({required VoidCallback onRewarded}) async {
    if (!_config.adsEnabled || !_config.rewardedEnabled) return false;

    final allowed = await AdFrequencyManager.instance.canShowRewarded();
    if (!allowed) return false;

    if (_rewardedAd == null) return false;

    final ad = _rewardedAd!;
    _rewardedAd = null; // mark consumed before show to prevent double-tap

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewarded();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _loadRewarded();
        if (kDebugMode) {
          debugPrint('[$_tag] Rewarded show failed: ${err.message}');
        }
      },
      onAdShowedFullScreenContent: (_) {
        _logEvent('ad_impression', {'format': 'rewarded'});
      },
    );

    await ad.show(
      onUserEarnedReward: (_, reward) {
        // ONLY place where onRewarded is called — Google guarantees the reward.
        AdFrequencyManager.instance.recordRewardedShown();
        _logEvent('ad_reward_earned', {'format': 'rewarded'});
        onRewarded();
      },
    );

    return true;
  }

  // ── Rewarded Interstitial ─────────────────────────────────────────────────

  void _loadRewardedInterstitial() {
    if (_rewardedInterstitialLoading || _rewardedInterstitialAd != null) return;
    _rewardedInterstitialLoading = true;

    RewardedInterstitialAd.load(
      adUnitId: AdIds.rewardedInterstitialAdUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedInterstitialAd = ad;
          _rewardedInterstitialLoading = false;
          _rewardedInterstitialRetries = 0;
          if (kDebugMode) debugPrint('[$_tag] RewardedInterstitial loaded.');
        },
        onAdFailedToLoad: (err) {
          _rewardedInterstitialLoading = false;
          if (kDebugMode) {
            debugPrint(
                '[$_tag] RewardedInterstitial load failed: ${err.message}');
          }
          _scheduleRetry(() => _loadRewardedInterstitial(),
              _rewardedInterstitialRetries++, 'rew_int');
        },
      ),
    );
  }

  /// Shows a rewarded-interstitial ad. Pilot: max 1/session.
  ///
  /// [onRewarded] fires ONLY inside `onUserEarnedReward`.
  /// Returns `true` if the ad was shown.
  Future<bool> showRewardedInterstitialAd(
      {required VoidCallback onRewarded}) async {
    if (!_config.adsEnabled || !_config.rewardedInterstitialEnabled) {
      return false;
    }

    final allowed =
        await AdFrequencyManager.instance.canShowRewardedInterstitial();
    if (!allowed) return false;

    if (_rewardedInterstitialAd == null) return false;

    final ad = _rewardedInterstitialAd!;
    _rewardedInterstitialAd = null;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _loadRewardedInterstitial();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _loadRewardedInterstitial();
      },
      onAdShowedFullScreenContent: (_) {
        _logEvent('ad_impression', {'format': 'rewarded_interstitial'});
      },
    );

    await ad.show(
      onUserEarnedReward: (_, reward) {
        AdFrequencyManager.instance.recordRewardedInterstitialShown();
        _logEvent('ad_reward_earned', {'format': 'rewarded_interstitial'});
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
          if (kDebugMode) debugPrint('[$_tag] Interstitial loaded.');
        },
        onAdFailedToLoad: (err) {
          _interstitialLoading = false;
          if (kDebugMode) {
            debugPrint('[$_tag] Interstitial load failed: ${err.message}');
          }
          _scheduleRetry(() => _loadInterstitial(), _interstitialRetries++,
              'interstitial');
        },
      ),
    );
  }

  /// Call after each quiz completion. Shows an interstitial every
  /// [AdConfig.interstitialFrequency] completions if loaded and policy allows.
  Future<void> recordQuizCompletion() async {
    if (!_config.adsEnabled || !_config.interstitialEnabled) return;

    _quizCompletions++;
    if (_quizCompletions % _config.interstitialFrequency == 0) {
      await _showInterstitialIfAllowed();
    }
  }

  Future<void> _showInterstitialIfAllowed() async {
    final allowed = await AdFrequencyManager.instance.canShowInterstitial();
    if (!allowed || _interstitialAd == null) return;

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
      onAdShowedFullScreenContent: (_) {
        AdFrequencyManager.instance.recordInterstitialShown();
        _logEvent('ad_impression', {'format': 'interstitial'});
      },
    );

    ad.show();
  }

  // ── App-Open ──────────────────────────────────────────────────────────────

  void _loadAppOpenAd() {
    if (!_config.appOpenEnabled) return;
    if (_appOpenLoading || _appOpenAd != null) return;
    _appOpenLoading = true;

    AppOpenAd.load(
      adUnitId: AdIds.appOpenAdUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _appOpenLoading = false;
          _appOpenRetries = 0;
          if (kDebugMode) debugPrint('[$_tag] AppOpen loaded.');
        },
        onAdFailedToLoad: (err) {
          _appOpenLoading = false;
          if (kDebugMode) {
            debugPrint('[$_tag] AppOpen load failed: ${err.message}');
          }
          _scheduleRetry(() => _loadAppOpenAd(), _appOpenRetries++, 'app_open');
        },
      ),
    );
  }

  Future<void> _showAppOpenIfReady() async {
    if (!_config.adsEnabled || !_config.appOpenEnabled) return;
    if (_appOpenShowing || _appOpenAd == null) return;

    final allowed = await AdFrequencyManager.instance.canShowAppOpen();
    if (!allowed) return;

    final ad = _appOpenAd!;
    _appOpenAd = null;
    _appOpenShowing = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _appOpenShowing = false;
        _loadAppOpenAd();
      },
      onAdFailedToShowFullScreenContent: (ad, err) {
        ad.dispose();
        _appOpenShowing = false;
        _loadAppOpenAd();
      },
      onAdShowedFullScreenContent: (_) {
        AdFrequencyManager.instance.recordAppOpenShown();
        _logEvent('ad_impression', {'format': 'app_open'});
      },
    );

    ad.show();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _scheduleRetry(VoidCallback load, int attempt, String label) {
    if (attempt >= _maxRetries) {
      if (kDebugMode) debugPrint('[$_tag] $label: max retries reached.');
      return;
    }
    final delay = Duration(seconds: pow(2, attempt + 1).toInt());
    Timer(delay, load);
  }

  void _logEvent(String name, Map<String, Object> params) {
    FirebaseAnalytics.instance
        .logEvent(name: name, parameters: params)
        .ignore();
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
    _interstitialAd?.dispose();
    _appOpenAd?.dispose();
  }
}
