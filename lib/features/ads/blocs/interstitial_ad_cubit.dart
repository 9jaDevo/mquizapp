import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/system_config/model/ad_type.dart';
import 'package:flutterquiz/features/ads/utils/ad_analytics_collector.dart';
import 'package:flutterquiz/features/ads/utils/geographic_segmentation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:ironsource_mediation/ironsource_mediation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

sealed class InterstitialAdState {
  const InterstitialAdState();
}

final class InterstitialAdInitial extends InterstitialAdState {
  const InterstitialAdInitial();
}

final class InterstitialAdLoaded extends InterstitialAdState {
  const InterstitialAdLoaded();
}

final class InterstitialAdLoadInProgress extends InterstitialAdState {
  const InterstitialAdLoadInProgress();
}

final class InterstitialAdFailToLoad extends InterstitialAdState {
  const InterstitialAdFailToLoad();
}

/// Manages interstitial ad frequency capping to prevent ad stacking violations
class AdFrequencyManager {
  static const String _lastAdShowTimeKey = 'last_interstitial_show_time';
  static const String _dailyAdCountKey = 'daily_interstitial_count';
  static const String _dailyAdCountDateKey = 'daily_interstitial_count_date';

  /// Check if enough time has passed since last ad and daily limit not exceeded
  static Future<bool> canShowAd() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nowUtc = DateTime.now().toUtc();
      final limits = await GeographicSegmentation.getFrequencyLimits();

      // Check time gap using regional limits.
      final lastShowTime = prefs.getInt(_lastAdShowTimeKey) ?? 0;
      final timeSinceLastAd = nowUtc.millisecondsSinceEpoch - lastShowTime;
      if (timeSinceLastAd < limits.minInterstitialGapMs) {
        await AdAnalyticsCollector.recordComplianceEvent(
          eventName: 'frequency_cap_hit',
          payload: {
            'format': 'interstitial',
            'reason': 'min_gap',
            'elapsed_ms': timeSinceLastAd,
            'required_ms': limits.minInterstitialGapMs,
          },
        );
        log(
          '🛑 [FREQ-CAP] Ad blocked: Only ${timeSinceLastAd ~/ 1000}s since last (need ${limits.minInterstitialGapMs ~/ 1000}s)',
          name: 'AdFrequency-Diagnostic',
        );
        return false;
      }

      // Check daily limit
      final lastCountDate = prefs.getString(_dailyAdCountDateKey) ?? '';
      final todayDate =
          '${nowUtc.year.toString().padLeft(4, '0')}-${nowUtc.month.toString().padLeft(2, '0')}-${nowUtc.day.toString().padLeft(2, '0')}';

      int dailyCount = 0;
      if (lastCountDate == todayDate) {
        dailyCount = prefs.getInt(_dailyAdCountKey) ?? 0;
      }

      if (dailyCount >= limits.maxInterstitialsPerDay) {
        await AdAnalyticsCollector.recordComplianceEvent(
          eventName: 'frequency_cap_hit',
          payload: {
            'format': 'interstitial',
            'reason': 'daily_limit',
            'daily_count': dailyCount,
            'max_per_day': limits.maxInterstitialsPerDay,
          },
        );
        log(
          '🛑 [FREQ-CAP] Ad blocked: Daily limit reached ($dailyCount/${limits.maxInterstitialsPerDay})',
          name: 'AdFrequency-Diagnostic',
        );
        return false;
      }

      log(
        '✅ [FREQ-CAP] Can show ad | Time check: pass | Daily count: $dailyCount/${limits.maxInterstitialsPerDay}',
        name: 'AdFrequency-Diagnostic',
      );
      return true;
    } catch (e) {
      log(
        '❌ [FREQ-CAP] Error in canShowAd: $e',
        name: 'AdFrequency-Diagnostic',
        error: e,
      );
      return true; // Allow ad on error to avoid breaking functionality
    }
  }

  /// Record that an ad was shown
  static Future<void> recordAdShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final nowUtc = DateTime.now().toUtc();
      final limits = await GeographicSegmentation.getFrequencyLimits();

      // Update last show time
      await prefs.setInt(_lastAdShowTimeKey, nowUtc.millisecondsSinceEpoch);

      // Update daily count
      final todayDate =
          '${nowUtc.year.toString().padLeft(4, '0')}-${nowUtc.month.toString().padLeft(2, '0')}-${nowUtc.day.toString().padLeft(2, '0')}';
      final lastCountDate = prefs.getString(_dailyAdCountDateKey) ?? '';

      int dailyCount = 0;
      if (lastCountDate == todayDate) {
        dailyCount = prefs.getInt(_dailyAdCountKey) ?? 0;
      }

      await prefs.setInt(_dailyAdCountKey, dailyCount + 1);
      await prefs.setString(_dailyAdCountDateKey, todayDate);

      log(
        '✅ [FREQ-CAP] Ad recorded shown: ${dailyCount + 1}/${limits.maxInterstitialsPerDay} for today',
        name: 'AdFrequency-Diagnostic',
      );
    } catch (e) {
      log(
        '❌ [FREQ-CAP] Error in recordAdShown: $e',
        name: 'AdFrequency-Diagnostic',
        error: e,
      );
    }
  }

  /// Reset daily count (for testing - remove in production if needed)
  static Future<void> resetDailyCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_dailyAdCountKey);
      await prefs.remove(_dailyAdCountDateKey);
    } catch (e) {
      log('Error in resetDailyCount: $e', name: 'AdFrequency', error: e);
    }
  }
}

class InterstitialAdCubit extends Cubit<InterstitialAdState>
    with LevelPlayInterstitialAdListener {
  InterstitialAdCubit() : super(const InterstitialAdInitial());

  InterstitialAd? _interstitialAd;
  late LevelPlayInterstitialAd _ironSourceAd;

  InterstitialAd? get interstitialAd => _interstitialAd;

  final unityPlacementName = Platform.isIOS
      ? 'Interstitial_iOS'
      : 'Interstitial_Android';

  void _createGoogleInterstitialAd(BuildContext context) {
    InterstitialAd.load(
      adUnitId: context.read<SystemConfigCubit>().googleInterstitialAdId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _interstitialAd = ad;
          emit(const InterstitialAdLoaded());
        },
        onAdFailedToLoad: (err) {
          emit(const InterstitialAdFailToLoad());
        },
      ),
    );
  }

  void _createUnityAds() {
    UnityAds.load(
      placementId: unityPlacementName,
      onComplete: (placementId) => emit(const InterstitialAdLoaded()),
      onFailed: (placementId, err, msg) =>
          emit(const InterstitialAdFailToLoad()),
    );
  }

  Future<void> _createIronSourceAd(String adUnitId) async {
    _ironSourceAd = LevelPlayInterstitialAd(adUnitId: adUnitId);
    _ironSourceAd.setListener(this);
    await _ironSourceAd.loadAd();
  }

  void createInterstitialAd(BuildContext context) {
    final systemConfigCubit = context.read<SystemConfigCubit>();
    final showAds =
        systemConfigCubit.isAdsEnable &&
        !context.read<UserDetailsCubit>().removeAds();

    if (!showAds) {
      log(
        '⏭️ [INTERSTITIAL] Create skipped (ads disabled)',
        name: 'InterstitialAd-Diagnostic',
      );
      return;
    }

    emit(const InterstitialAdLoadInProgress());
    log(
      '🔄 [INTERSTITIAL] Creating interstitial ad | Network: ${systemConfigCubit.adsType}',
      name: 'InterstitialAd-Diagnostic',
    );

    final adsType = systemConfigCubit.adsType;
    if (adsType == AdType.admob) {
      _createGoogleInterstitialAd(context);
    } else if (adsType == AdType.unity) {
      _createUnityAds();
    } else if (adsType == AdType.ironSource) {
      final adUnitId = systemConfigCubit.ironSourceInterstitialId;
      if (adUnitId.isNotEmpty) {
        log(
          '✅ [INTERSTITIAL] IronSource ID: $adUnitId',
          name: 'InterstitialAd-Diagnostic',
        );
        _createIronSourceAd(adUnitId);
      } else {
        log(
          '❌ [INTERSTITIAL] IronSource ID NOT configured',
          name: 'InterstitialAd-Diagnostic',
        );
        emit(const InterstitialAdFailToLoad());
      }
    }
  }

  Future<void> showAd(BuildContext context) async {
    // Check frequency capping first (AdMob compliance)
    final canShowAd = await AdFrequencyManager.canShowAd();
    if (!canShowAd) {
      log(
        '🛑 [INTERSTITIAL] Show blocked by frequency capping',
        name: 'InterstitialAd-Diagnostic',
      );
      return;
    }

    log(
      '📊 [INTERSTITIAL] Show attempt | State: $state',
      name: 'InterstitialAd-Diagnostic',
    );

    //if ad is enable
    final sysConfigCubit = context.read<SystemConfigCubit>();
    if (sysConfigCubit.isAdsEnable &&
        !context.read<UserDetailsCubit>().removeAds()) {
      //if ad loaded succesfully
      if (state is InterstitialAdLoaded) {
        log(
          '✅ [INTERSTITIAL] Attempting to show ads',
          name: 'InterstitialAd-Diagnostic',
        );
        //show google interstitial ad
        if (sysConfigCubit.adsType == AdType.admob) {
          interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {
              log(
                '✅ [INTERSTITIAL] Google ad shown to user',
                name: 'InterstitialAd-Diagnostic',
              );
              // Record ad as shown for frequency tracking
              AdFrequencyManager.recordAdShown();
            },
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              log(
                '✅ [INTERSTITIAL] Google ad dismissed | Creating next ad',
                name: 'InterstitialAd-Diagnostic',
              );
              ad.dispose();
              createInterstitialAd(context);
            },
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
                  log(
                    '❌ [INTERSTITIAL] Google ad failed to show: $error',
                    name: 'InterstitialAd-Diagnostic',
                  );
                  ad.dispose();
                  createInterstitialAd(context);
                },
          );
          interstitialAd?.show();
        } else if (sysConfigCubit.adsType == AdType.unity) {
          //show Unity interstitial ad
          UnityAds.showVideoAd(
            placementId: unityPlacementName,
            onStart: (placementId) {
              log(
                '✅ [INTERSTITIAL] Unity ad started playing',
                name: 'InterstitialAd-Diagnostic',
              );
              // Record ad as shown for frequency tracking
              AdFrequencyManager.recordAdShown();
            },
            onComplete: (placementId) {
              log(
                '✅ [INTERSTITIAL] Unity ad completed | Creating next ad',
                name: 'InterstitialAd-Diagnostic',
              );
              createInterstitialAd(context);
            },
            onFailed: (placementId, error, message) {
              log(
                '❌ [INTERSTITIAL] Unity ad failed: $error $message',
                name: 'InterstitialAd-Diagnostic',
              );
              createInterstitialAd(context);
            },
            onClick: (placementId) => log(
              '👆 [INTERSTITIAL] Unity ad clicked',
              name: 'InterstitialAd-Diagnostic',
            ),
            onSkipped: (placementId) {
              log(
                '⏭️ [INTERSTITIAL] Unity ad skipped',
                name: 'InterstitialAd-Diagnostic',
              );
              createInterstitialAd(context);
            },
          );
        } else if (sysConfigCubit.adsType == AdType.ironSource) {
          if (await _ironSourceAd.isAdReady()) {
            log(
              '✅ [INTERSTITIAL] IronSource ad ready | Showing...',
              name: 'InterstitialAd-Diagnostic',
            );
            // Record ad as shown for frequency tracking
            await AdFrequencyManager.recordAdShown();
            await _ironSourceAd.showAd().then((_) {
              log(
                '✅ [INTERSTITIAL] IronSource ad completed | Creating next ad',
                name: 'InterstitialAd-Diagnostic',
              );
              createInterstitialAd(context);
            });
          } else {
            log(
              '❌ [INTERSTITIAL] IronSource ad not ready',
              name: 'InterstitialAd-Diagnostic',
            );
          }
        }
      } else if (state is InterstitialAdFailToLoad) {
        log(
          '⚠️ [INTERSTITIAL] Previous load failed | Retrying...',
          name: 'InterstitialAd-Diagnostic',
        );
        createInterstitialAd(context);
      } else {
        log(
          '⚠️ [INTERSTITIAL] Ad not loaded yet (state: $state)',
          name: 'InterstitialAd-Diagnostic',
        );
      }
    } else {
      log(
        '⏭️ [INTERSTITIAL] Show skipped (ads disabled)',
        name: 'InterstitialAd-Diagnostic',
      );
    }
  }

  @override
  Future<void> close() async {
    await _interstitialAd?.dispose();
    await _ironSourceAd.dispose();

    return super.close();
  }

  @override
  void onAdClicked(LevelPlayAdInfo adInfo) {
    log('onAdClicked $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdClosed(LevelPlayAdInfo adInfo) {
    log('onAdClosed $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdDisplayFailed(LevelPlayAdError error, LevelPlayAdInfo adInfo) {
    log('onAdDisplayFailed $adInfo', name: 'LevelPlay', error: error);
  }

  @override
  void onAdDisplayed(LevelPlayAdInfo adInfo) {
    log('onAdDisplayed $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdInfoChanged(LevelPlayAdInfo adInfo) {
    log('onAdInfoChanged $adInfo', name: 'LevelPlay');
  }

  @override
  void onAdLoadFailed(LevelPlayAdError error) {
    emit(const InterstitialAdFailToLoad());
    log('onAdLoadFailed', name: 'LevelPlay', error: error);
  }

  @override
  void onAdLoaded(LevelPlayAdInfo adInfo) {
    emit(const InterstitialAdLoaded());
    log('onAdLoaded $adInfo', name: 'LevelPlay');
  }
}
