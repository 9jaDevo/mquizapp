import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/system_config/model/ad_type.dart';
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

  // Minimum gap between interstitials in milliseconds (120 seconds)
  static const int _minGapBetweenAds = 120000;

  // Maximum interstitials per day
  static const int _maxAdsPerDay = 3;

  /// Check if enough time has passed since last ad and daily limit not exceeded
  static Future<bool> canShowAd() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // Check time gap (minimum 120 seconds between ads)
      final lastShowTime = prefs.getInt(_lastAdShowTimeKey) ?? 0;
      final timeSinceLastAd = now.millisecondsSinceEpoch - lastShowTime;
      if (timeSinceLastAd < _minGapBetweenAds) {
        log(
          'Ad blocked: Only ${timeSinceLastAd ~/ 1000}s since last ad (need ${_minGapBetweenAds ~/ 1000}s)',
          name: 'AdFrequency',
        );
        return false;
      }

      // Check daily limit
      final lastCountDate = prefs.getString(_dailyAdCountDateKey) ?? '';
      final todayDate = '${now.year}-${now.month}-${now.day}';

      int dailyCount = 0;
      if (lastCountDate == todayDate) {
        dailyCount = prefs.getInt(_dailyAdCountKey) ?? 0;
      }

      if (dailyCount >= _maxAdsPerDay) {
        log(
          'Ad blocked: Daily limit reached ($dailyCount/$_maxAdsPerDay)',
          name: 'AdFrequency',
        );
        return false;
      }

      return true;
    } catch (e) {
      log('Error in canShowAd: $e', name: 'AdFrequency', error: e);
      return true; // Allow ad on error to avoid breaking functionality
    }
  }

  /// Record that an ad was shown
  static Future<void> recordAdShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // Update last show time
      await prefs.setInt(_lastAdShowTimeKey, now.millisecondsSinceEpoch);

      // Update daily count
      final todayDate = '${now.year}-${now.month}-${now.day}';
      final lastCountDate = prefs.getString(_dailyAdCountDateKey) ?? '';

      int dailyCount = 0;
      if (lastCountDate == todayDate) {
        dailyCount = prefs.getInt(_dailyAdCountKey) ?? 0;
      }

      await prefs.setInt(_dailyAdCountKey, dailyCount + 1);
      await prefs.setString(_dailyAdCountDateKey, todayDate);

      log(
        'Ad recorded: ${dailyCount + 1}/$_maxAdsPerDay for today',
        name: 'AdFrequency',
      );
    } catch (e) {
      log('Error in recordAdShown: $e', name: 'AdFrequency', error: e);
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

    if (!showAds) return;

    emit(const InterstitialAdLoadInProgress());

    final adsType = systemConfigCubit.adsType;
    if (adsType == AdType.admob) {
      _createGoogleInterstitialAd(context);
    } else if (adsType == AdType.unity) {
      _createUnityAds();
    } else if (adsType == AdType.ironSource) {
      final adUnitId = systemConfigCubit.ironSourceInterstitialId;
      if (adUnitId.isNotEmpty) {
        _createIronSourceAd(adUnitId);
      } else {
        emit(const InterstitialAdFailToLoad());
      }
    }
  }

  Future<void> showAd(BuildContext context) async {
    // Check frequency capping first (AdMob compliance)
    final canShowAd = await AdFrequencyManager.canShowAd();
    if (!canShowAd) {
      log('Ad not shown due to frequency cap', name: 'InterstitialAd');
      return;
    }

    //if ad is enable
    final sysConfigCubit = context.read<SystemConfigCubit>();
    if (sysConfigCubit.isAdsEnable &&
        !context.read<UserDetailsCubit>().removeAds()) {
      //if ad loaded succesfully
      if (state is InterstitialAdLoaded) {
        //show google interstitial ad
        if (sysConfigCubit.adsType == AdType.admob) {
          interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdShowedFullScreenContent: (InterstitialAd ad) {
              // Record ad as shown for frequency tracking
              AdFrequencyManager.recordAdShown();
            },
            onAdDismissedFullScreenContent: (InterstitialAd ad) {
              ad.dispose();
              createInterstitialAd(context);
            },
            onAdFailedToShowFullScreenContent:
                (InterstitialAd ad, AdError error) {
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
              // Record ad as shown for frequency tracking
              AdFrequencyManager.recordAdShown();
              log('Video Ad $placementId started');
            },
            onComplete: (placementId) => createInterstitialAd(context),
            onFailed: (placementId, error, message) =>
                log('Video Ad $placementId failed: $error $message'),
            onClick: (placementId) => log('Video Ad $placementId click'),
            onSkipped: (placementId) => createInterstitialAd(context),
          );
        } else if (sysConfigCubit.adsType == AdType.ironSource) {
          if (await _ironSourceAd.isAdReady()) {
            // Record ad as shown for frequency tracking
            await AdFrequencyManager.recordAdShown();
            await _ironSourceAd.showAd().then((_) {
              createInterstitialAd(context);
            });
          }
        }
      } else if (state is InterstitialAdFailToLoad) {
        createInterstitialAd(context);
      }
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
