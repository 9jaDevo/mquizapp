import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/commons/widgets/custom_snackbar.dart';
import 'package:flutterquiz/features/ads/utils/ad_consent_tracker.dart';
import 'package:flutterquiz/features/ads/utils/ad_impression_quality_tracker.dart';
import 'package:flutterquiz/features/ads/utils/ad_analytics_collector.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/system_config/model/ad_type.dart';
import 'package:flutterquiz/ui/widgets/ad_consent_dialog.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum RewardedInterstitialAdState { initial, loading, loaded, failure }

/// Rewarded Interstitial Ads - Full-page ads that reward users
/// Combines premium eCPM of interstitials with engagement of rewarded
/// Expected eCPM: $3-6 (higher than regular rewarded ads)
class RewardedInterstitialAdCubit extends Cubit<RewardedInterstitialAdState> {
  RewardedInterstitialAdCubit() : super(RewardedInterstitialAdState.initial);

  RewardedInterstitialAd? _rewardedInterstitialAd;
  static const String _adId = 'rewarded_interstitial_standard';

  /// Create rewarded interstitial ad
  Future<void> createRewardedInterstitialAd(BuildContext context) async {
    if (!context.mounted) return;

    final config = context.read<SystemConfigCubit>();
    final showAds =
        config.isAdsEnable && !context.read<UserDetailsCubit>().removeAds();

    if (!showAds) {
      log('⏭️ [REWARD-INT] Create skipped (ads disabled)', name: 'RewardedInterstitialAd-Diagnostic');
      return;
    }

    // Only support AdMob for rewarded interstitial
    if (config.adsType != AdType.admob) {
      log(
        '⏭️ [REWARD-INT] Only AdMob supported | Got: ${config.adsType}',
        name: 'RewardedInterstitialAd-Diagnostic',
      );
      return;
    }

    if (state == RewardedInterstitialAdState.loading ||
        state == RewardedInterstitialAdState.loaded) {
      log(
        '⏭️ [REWARD-INT] Already loading/loaded',
        name: 'RewardedInterstitialAd-Diagnostic',
      );
      return;
    }

    emit(RewardedInterstitialAdState.loading);

    // Get rewarded interstitial ad unit ID from backend config
    final adUnitId = config.rewardedInterstitialAdId;

    if (adUnitId.isEmpty) {
      log(
        '❌ [REWARD-INT] Ad unit ID NOT CONFIGURED in backend',
        name: 'RewardedInterstitialAd-Diagnostic',
      );
      emit(RewardedInterstitialAdState.initial);
      return;
    }

    log(
      '🔄 [REWARD-INT] Loading | AdUnitID: $adUnitId',
      name: 'RewardedInterstitialAd-Diagnostic',
    );

    await RewardedInterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
        onAdLoaded: (ad) async {
          _rewardedInterstitialAd = ad;
          emit(RewardedInterstitialAdState.loaded);

          // Track impression
          await AdImpressionQualityTracker.recordImpression(_adId);
          await AdAnalyticsCollector.recordImpressionMetric(
            'rewarded_interstitial_standard',
          );

          log(
            '✅ [REWARD-INT] Loaded successfully',
            name: 'RewardedInterstitialAd-Diagnostic',
          );
        },
        onAdFailedToLoad: (error) {
          log(
            '❌ [REWARD-INT] Failed to load: $error',
            name: 'RewardedInterstitialAd-Diagnostic',
          );
          emit(RewardedInterstitialAdState.failure);
          _rewardedInterstitialAd = null;
        },
      ),
    );
  }

  /// Show consent dialog before displaying ad
  Future<bool> _showConsentDialog(
    BuildContext context,
    int rewardAmount,
    String rewardCurrencyLabel,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AdConsentDialog(
        rewardAmount: rewardAmount,
        rewardCurrencyLabel: rewardCurrencyLabel,
        onWatchAdTap: () {
          AdConsentTracker.recordConsent('rewarded_interstitial');
          Navigator.pop(context, true);
        },
        onSkipTap: () {
          AdConsentTracker.recordRejection('rewarded_interstitial');
          Navigator.pop(context, false);
        },
      ),
    );

    return result ?? false;
  }

  /// Show rewarded interstitial ad with consent dialog
  Future<void> showAd({
    required BuildContext context,
    required VoidCallback onAdDismissedCallback,
    int rewardAmount = 15, // Higher than regular rewarded (10 coins)
    String rewardCurrencyLabel = 'coins',
  }) async {
    if (!context.mounted) return;

    if (_rewardedInterstitialAd == null ||
        state != RewardedInterstitialAdState.loaded) {
      log('Rewarded interstitial ad not ready', name: 'RewardedInterstitialAd');
      onAdDismissedCallback();
      return;
    }

    // Show consent dialog first (AdMob compliance)
    final userConsented = await _showConsentDialog(
      context,
      rewardAmount,
      rewardCurrencyLabel,
    );

    if (!userConsented) {
      log(
        'User skipped rewarded interstitial ad',
        name: 'RewardedInterstitialAd',
      );
      // User declined, reload ad for next time
      if (context.mounted) {
        createRewardedInterstitialAd(context);
      }
      onAdDismissedCallback();
      return;
    }

    bool rewardEarned = false;

    _rewardedInterstitialAd!
        .fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        log(
          'Rewarded interstitial showed full screen',
          name: 'RewardedInterstitialAd',
        );
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log(
          'Rewarded interstitial failed to show: $error',
          name: 'RewardedInterstitialAd',
        );
        ad.dispose();
        _rewardedInterstitialAd = null;
        emit(RewardedInterstitialAdState.initial);
        if (context.mounted) {
          createRewardedInterstitialAd(context);
        }
        onAdDismissedCallback();
      },
      onAdDismissedFullScreenContent: (ad) async {
        log(
          'Rewarded interstitial dismissed (earned: $rewardEarned)',
          name: 'RewardedInterstitialAd',
        );
        ad.dispose();
        _rewardedInterstitialAd = null;
        emit(RewardedInterstitialAdState.initial);

        // Reward user if they watched to completion
        if (rewardEarned && context.mounted) {
          final userDetails = context.read<UserDetailsCubit>();

          // Update user coins
          userDetails.updateCoins(
            addCoin: true,
            coins: rewardAmount,
          );

          // Refresh user details
          await userDetails.fetchUserDetails();

          // Track conversion
          await AdAnalyticsCollector.recordConversionMetric(
            'rewarded_interstitial_standard',
          );

          if (context.mounted) {
            context.showSnack(
              '+$rewardAmount coins earned!',
            );
          }
        }

        // Reload ad for next time
        if (context.mounted) {
          createRewardedInterstitialAd(context);
        }
        onAdDismissedCallback();
      },
      onAdClicked: (ad) async {
        log('Rewarded interstitial clicked', name: 'RewardedInterstitialAd');
        await AdImpressionQualityTracker.recordClickAndGetQuality(_adId);
        await AdAnalyticsCollector.recordClickMetric(
          'rewarded_interstitial_standard',
        );
      },
    );

    await _rewardedInterstitialAd!.show(
      onUserEarnedReward: (ad, reward) {
        log(
          'User earned reward: ${reward.amount} ${reward.type}',
          name: 'RewardedInterstitialAd',
        );
        rewardEarned = true;
      },
    );
  }

  @override
  Future<void> close() async {
    await _rewardedInterstitialAd?.dispose();
    return super.close();
  }
}
