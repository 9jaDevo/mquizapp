import 'dart:developer';
import 'dart:io';
import 'dart:math' show min;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutterquiz/features/ads/utils/banner_visibility_tracker.dart';
import 'package:flutterquiz/features/ads/utils/ad_impression_quality_tracker.dart';
import 'package:flutterquiz/features/profile_management/cubits/user_details_cubit.dart';
import 'package:flutterquiz/features/system_config/cubits/system_config_cubit.dart';
import 'package:flutterquiz/features/system_config/model/ad_type.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

enum BannerAdState { initial, loading, loaded, failure }

class BannerAdCubit extends Cubit<BannerAdState> {
  BannerAdCubit() : super(BannerAdState.initial);

  BannerAd? _googleBannerAd;
  UnityBannerAd? _unityBannerAd;
  
  // Lazy loading tracking
  bool _lazyLoadingInitiated = false;
  static const String _bannerAdId = 'banner_standard';

  BannerAd? get googleBannerAd => _googleBannerAd;
  UnityBannerAd? get unityBannerAd => _unityBannerAd;

  int _bannerRetryCount = 0;
  static const int _maxRetryCount = 3;

  Future<void> _createGoogleBannerAd(BuildContext context) async {
    await _googleBannerAd?.dispose();
    _googleBannerAd = null;

    final size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
          MediaQuery.sizeOf(context).width.truncate(),
        ) ??
        AdSize.banner;

    final startTime = DateTime.now().millisecondsSinceEpoch;

    final ad = BannerAd(
      request: const AdRequest(),
      adUnitId: context.read<SystemConfigCubit>().googleBannerId,
      listener: BannerAdListener(
        onAdLoaded: (ad) async {
          _bannerRetryCount = 0; // Reset

          _googleBannerAd = ad as BannerAd;
          
          // Track impression quality
          await AdImpressionQualityTracker.recordImpression(_bannerAdId);
          
          // Record ad load time for performance monitoring
          final loadDuration = DateTime.now().millisecondsSinceEpoch - startTime;
          await BannerVisibilityTracker.recordAdLoadTime(_bannerAdId, loadDuration);
          
          emit(BannerAdState.loaded);
          log('BannerAd loaded (${loadDuration}ms)');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) async {
          await ad.dispose(); // Dispose failed ad
          log('BannerAd failedToLoad: $error');
          emit(BannerAdState.failure);

          if (error.code == 3 && _bannerRetryCount < _maxRetryCount) {
            final delay = Duration(seconds: min(2 << _bannerRetryCount, 10));
            _bannerRetryCount++;

            log('Retrying in ${delay.inSeconds}s (attempt $_bannerRetryCount)');
            await Future<void>.delayed(delay);
            await _createGoogleBannerAd(context); // Retry recursively
          } else {
            log('Stopped retrying after $_bannerRetryCount attempts.');
          }
        },
        onAdOpened: (_) => log('BannerAd opened'),
        onAdClosed: (_) => log('BannerAd closed'),
      ),
      size: size,
    );

    await ad.load();
  }

  void _createUnityBannerAd() {
    _unityBannerAd = null;
    final placementName = Platform.isIOS ? 'Banner_iOS' : 'Banner_Android';
    
    final startTime = DateTime.now().millisecondsSinceEpoch;

    _unityBannerAd = UnityBannerAd(
      placementId: placementName,
      onLoad: (_) async {
        _bannerRetryCount = 0; // Reset
        
        // Track impression quality
        await AdImpressionQualityTracker.recordImpression(_bannerAdId);
        
        // Record ad load time for performance monitoring
        final loadDuration = DateTime.now().millisecondsSinceEpoch - startTime;
        await BannerVisibilityTracker.recordAdLoadTime(_bannerAdId, loadDuration);
        
        log('BannerAd loaded (${loadDuration}ms)');
        emit(BannerAdState.loaded);
      },
      onFailed: (placementId, error, message) async {
        log('Banner Ad $placementId failed: $error $message');
        emit(BannerAdState.failure);

        if (_bannerRetryCount < _maxRetryCount) {
          final delay = Duration(seconds: min(2 << _bannerRetryCount, 10));
          _bannerRetryCount++;

          log('Retrying in ${delay.inSeconds}s (attempt $_bannerRetryCount)');
          await Future<void>.delayed(delay);
          _createUnityBannerAd(); // Retry
        } else {
          log('Stopped retrying after $_bannerRetryCount attempts.');
        }
      },
    );
  }

  void initBannerAd(BuildContext context) {
    final config = context.read<SystemConfigCubit>();
    final showAds =
        config.isAdsEnable && !context.read<UserDetailsCubit>().removeAds();

    if (!showAds) return;

    // Record when banner becomes visible - lazy loading
    BannerVisibilityTracker.recordBannerVisible(_bannerAdId);
    
    // Only load ads if app is in resumed state (visible to user)
    if (context.mounted && BannerVisibilityTracker.isScreenVisible(context)) {
      _loadBannerAd(context);
    } else {
      // Defer loading until later when screen might be visible
      log('Deferring banner ad load (screen not visible yet)', name: 'BannerAd');
      _lazyLoadingInitiated = true;
    }
  }

  /// Load banner ad after visibility check (lazy loading pattern)
  Future<void> _loadBannerAd(BuildContext context) async {
    if (!context.mounted) return;
    
    final config = context.read<SystemConfigCubit>();
    final showAds =
        config.isAdsEnable && !context.read<UserDetailsCubit>().removeAds();

    if (!showAds) return;

    // Check if we should load based on visibility duration
    final shouldLoad = await BannerVisibilityTracker.shouldLoadBanner(_bannerAdId);
    if (!shouldLoad) {
      log('Waiting for banner to be visible longer before loading', name: 'BannerAd');
      Future.delayed(Duration(milliseconds: 500), () => _loadBannerAd(context));
      return;
    }

    if (config.adsType == AdType.admob) {
      _createGoogleBannerAd(context);
    } else if (config.adsType == AdType.unity) {
      _createUnityBannerAd();
    } else if (config.adsType == AdType.ironSource) {
      if (config.ironSourceBannerId.isNotEmpty) {
        emit(BannerAdState.loaded);
      } else {
        emit(BannerAdState.failure);
      }
    }
  }

  /// Try to load banner if deferred (called from app resume)
  void retryDeferredLoad(BuildContext context) {
    if (_lazyLoadingInitiated && state == BannerAdState.initial) {
      log('Retrying deferred banner ad load', name: 'BannerAd');
      _loadBannerAd(context);
      _lazyLoadingInitiated = false;
    }
  }

  bool get bannerAdLoaded => state == BannerAdState.loaded;

  /// Get performance metrics for banner ad
  Future<Map<String, dynamic>> getPerformanceMetrics() async {
    final impressions = await AdImpressionQualityTracker.getImpressionCount(_bannerAdId);
    final clicks = await AdImpressionQualityTracker.getClickCount(_bannerAdId);
    final ctr = await AdImpressionQualityTracker.getClickThroughRate(_bannerAdId);
    final qualityScore = await AdImpressionQualityTracker.getQualityScore(_bannerAdId);
    final avgLoadTime = await BannerVisibilityTracker.getAverageLoadTime(_bannerAdId);

    return {
      'impressions': impressions,
      'clicks': clicks,
      'ctr_percent': ctr.toStringAsFixed(2),
      'quality_score': (qualityScore * 100).toStringAsFixed(1),
      'avg_load_time_ms': avgLoadTime.toStringAsFixed(0),
    };
  }

  @override
  Future<void> close() async {
    await _googleBannerAd?.dispose();
    // Clear visibility tracking
    await BannerVisibilityTracker.clearBannerVisibility(_bannerAdId);
    return super.close();
  }
}
