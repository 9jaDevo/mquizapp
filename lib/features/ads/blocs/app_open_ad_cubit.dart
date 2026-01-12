import 'dart:developer';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/ads/utils/ad_impression_quality_tracker.dart';
import 'package:flutterquiz/features/ads/utils/ad_analytics_collector.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/system_config/model/ad_type.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppOpenAdState { initial, loading, loaded, showing, failure }

/// App Open Ads appear when users launch or resume the app
/// High eCPM format ($2-8), shown at guaranteed high-intent moments
class AppOpenAdCubit extends Cubit<AppOpenAdState> {
  AppOpenAdCubit() : super(AppOpenAdState.initial);

  AppOpenAd? _appOpenAd;
  static const String _appOpenAdId = 'app_open_standard';
  static const String _lastShowTimeKey = 'app_open_last_show_time';
  static const String _appOpenCountKey = 'app_open_show_count_today';
  static const String _lastResetDateKey = 'app_open_last_reset_date';

  // Frequency controls
  static const Duration _minTimeBetweenAppOpens = Duration(
    hours: 4,
  ); // Show max once per 4 hours
  static const int _maxAppOpenAdsPerDay = 3; // Max 3 per day

  bool _isShowingAd = false;
  DateTime? _appOpenLoadTime;

  /// Check if we should show app open ad (frequency capping)
  Future<bool> canShowAppOpenAd() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Reset daily count if new day
      await _resetDailyCountIfNeeded(prefs);

      // Check last show time
      final lastShowTime = prefs.getInt(_lastShowTimeKey);
      if (lastShowTime != null) {
        final elapsed = DateTime.now().millisecondsSinceEpoch - lastShowTime;
        if (elapsed < _minTimeBetweenAppOpens.inMilliseconds) {
          log(
            'App open ad blocked: Too soon since last (${elapsed}ms < ${_minTimeBetweenAppOpens.inMilliseconds}ms)',
            name: 'AppOpenAd',
          );
          return false;
        }
      }

      // Check daily count
      final todayCount = prefs.getInt(_appOpenCountKey) ?? 0;
      if (todayCount >= _maxAppOpenAdsPerDay) {
        log(
          'App open ad blocked: Daily limit reached ($todayCount >= $_maxAppOpenAdsPerDay)',
          name: 'AppOpenAd',
        );
        return false;
      }

      return true;
    } catch (e) {
      log('Error checking app open frequency: $e', name: 'AppOpenAd');
      return false;
    }
  }

  /// Reset daily count at midnight
  Future<void> _resetDailyCountIfNeeded(SharedPreferences prefs) async {
    try {
      final lastResetDate = prefs.getString(_lastResetDateKey);
      final today = DateTime.now().toIso8601String().split('T')[0];

      if (lastResetDate != today) {
        await prefs.setInt(_appOpenCountKey, 0);
        await prefs.setString(_lastResetDateKey, today);
        log('App open daily count reset', name: 'AppOpenAd');
      }
    } catch (e) {
      log('Error resetting daily count: $e', name: 'AppOpenAd');
    }
  }

  /// Record when app open ad was shown
  Future<void> _recordAppOpenShown() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _lastShowTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      final currentCount = prefs.getInt(_appOpenCountKey) ?? 0;
      await prefs.setInt(_appOpenCountKey, currentCount + 1);

      log('App open ad shown (count: ${currentCount + 1})', name: 'AppOpenAd');
    } catch (e) {
      log('Error recording app open shown: $e', name: 'AppOpenAd');
    }
  }

  /// Load app open ad (called at app startup)
  Future<void> loadAppOpenAd(BuildContext context) async {
    if (!context.mounted) return;

    final config = context.read<SystemConfigCubit>();
    final showAds =
        config.isAdsEnable && !context.read<UserDetailsCubit>().removeAds();

    if (!showAds) {
      log('App open ads disabled', name: 'AppOpenAd');
      return;
    }

    // Only support AdMob for app open ads (premium format)
    if (config.adsType != AdType.admob) {
      log('App open ads only supported for AdMob', name: 'AppOpenAd');
      return;
    }

    if (state == AppOpenAdState.loading || state == AppOpenAdState.loaded) {
      log('App open ad already loading or loaded', name: 'AppOpenAd');
      return;
    }

    emit(AppOpenAdState.loading);

    // Get app open ad unit ID from backend config
    final adUnitId = config.appOpenAdId;

    if (adUnitId.isEmpty) {
      log('App open ad unit ID not configured in backend', name: 'AppOpenAd');
      emit(AppOpenAdState.initial);
      return;
    }

    log('Loading app open ad with ID: $adUnitId', name: 'AppOpenAd');

    await AppOpenAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) async {
          _appOpenAd = ad;
          _appOpenLoadTime = DateTime.now();
          emit(AppOpenAdState.loaded);

          // Track impression quality
          await AdImpressionQualityTracker.recordImpression(_appOpenAdId);
          await AdAnalyticsCollector.recordImpressionMetric(
            'app_open_standard',
          );

          log('App open ad loaded successfully', name: 'AppOpenAd');
        },
        onAdFailedToLoad: (error) {
          log('App open ad failed to load: $error', name: 'AppOpenAd');
          emit(AppOpenAdState.failure);
          _appOpenAd = null;
        },
      ),
    );
  }

  /// Show app open ad if loaded and frequency allows
  Future<void> showAppOpenAdIfAvailable() async {
    if (_isShowingAd) {
      log('Already showing ad', name: 'AppOpenAd');
      return;
    }

    if (_appOpenAd == null || state != AppOpenAdState.loaded) {
      log('App open ad not ready to show', name: 'AppOpenAd');
      return;
    }

    // Check if ad is too old (> 4 hours)
    if (_appOpenLoadTime != null) {
      final age = DateTime.now().difference(_appOpenLoadTime!);
      if (age > const Duration(hours: 4)) {
        log(
          'App open ad expired (age: ${age.inHours}h), disposing',
          name: 'AppOpenAd',
        );
        await _appOpenAd?.dispose();
        _appOpenAd = null;
        emit(AppOpenAdState.initial);
        return;
      }
    }

    // Check frequency capping
    final canShow = await canShowAppOpenAd();
    if (!canShow) {
      return;
    }

    _isShowingAd = true;
    emit(AppOpenAdState.showing);

    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) async {
        log('App open ad showed full screen', name: 'AppOpenAd');
        await _recordAppOpenShown();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        log('App open ad failed to show: $error', name: 'AppOpenAd');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        emit(AppOpenAdState.failure);
      },
      onAdDismissedFullScreenContent: (ad) async {
        log('App open ad dismissed', name: 'AppOpenAd');
        _isShowingAd = false;
        ad.dispose();
        _appOpenAd = null;
        emit(AppOpenAdState.initial);
      },
      onAdClicked: (ad) async {
        log('App open ad clicked', name: 'AppOpenAd');
        await AdImpressionQualityTracker.recordClickAndGetQuality(_appOpenAdId);
        await AdAnalyticsCollector.recordClickMetric('app_open_standard');
      },
    );

    await _appOpenAd!.show();
  }

  @override
  Future<void> close() async {
    await _appOpenAd?.dispose();
    return super.close();
  }
}
