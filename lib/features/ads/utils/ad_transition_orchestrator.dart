import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/ads/blocs/interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/ads/blocs/rewarded_interstitial_ad_cubit.dart';
import 'package:flutterquiz/features/ads/utils/ad_analytics_collector.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';

/// Handles policy-safe fallback for result/transition ad moments.
final class AdTransitionOrchestrator {
  const AdTransitionOrchestrator._();

  static Future<void> showResultTransitionAd({
    required BuildContext context,
    required int completionCount,
    required bool isPremiumCategory,
    required int rewardCoins,
  }) async {
    if (!context.mounted || isPremiumCategory) return;

    final config = context.read<SystemConfigCubit>();
    final adsRemoved = context.read<UserDetailsCubit>().removeAds();
    if (!config.isAdsEnable || adsRemoved) return;

    final interstitialCubit = context.read<InterstitialAdCubit>();

    // Prefer rewarded interstitial on every 2nd completion.
    if (completionCount % 2 == 0) {
      final rewardedInterstitialCubit = context
          .read<RewardedInterstitialAdCubit>();
      if (rewardedInterstitialCubit.state !=
          RewardedInterstitialAdState.loaded) {
        await rewardedInterstitialCubit.createRewardedInterstitialAd(context);
      }

      if (rewardedInterstitialCubit.state ==
          RewardedInterstitialAdState.loaded) {
        await AdAnalyticsCollector.recordComplianceEvent(
          eventName: 'transition_ad_selected',
          payload: {
            'placement': 'result_transition',
            'format': 'rewarded_interstitial',
            'completion_count': completionCount,
          },
        );
        await rewardedInterstitialCubit.showAd(
          context: context,
          rewardAmount: rewardCoins,
          rewardCurrencyLabel: 'coins',
          onAdDismissedCallback: () {},
        );
        return;
      }

      log(
        '[AD-FALLBACK] Rewarded interstitial unavailable; falling back to interstitial',
        name: 'AdTransitionOrchestrator',
      );
      await AdAnalyticsCollector.recordComplianceEvent(
        eventName: 'transition_ad_fallback',
        payload: {
          'placement': 'result_transition',
          'from': 'rewarded_interstitial',
          'to': 'interstitial',
          'completion_count': completionCount,
        },
      );
    }

    await AdAnalyticsCollector.recordComplianceEvent(
      eventName: 'transition_ad_selected',
      payload: {
        'placement': 'result_transition',
        'format': 'interstitial',
        'completion_count': completionCount,
      },
    );
    await interstitialCubit.showAd(context);
  }
}
