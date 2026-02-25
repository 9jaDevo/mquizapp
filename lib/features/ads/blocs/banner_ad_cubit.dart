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
    final adUnitId = context.read<SystemConfigCubit>().googleBannerId;
    final platform = Platform.isIOS ? 'iOS' : 'Android';
    log('🔄 [BANNER] Creating Google banner | Platform: $platform | AdUnitID: ${adUnitId.isEmpty ? "⚠️ MISSING" : adUnitId} | Size: ${size.width}x${size.height}', name: 'BannerAd-Diagnostic');

    final ad = BannerAd(
      request: const AdRequest(),
      adUnitId: adUnitId,
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
          log('✅ [BANNER] Google banner loaded! Duration: ${loadDuration}ms Size: ${ad.size.width}x${ad.size.height}', name: 'BannerAd-Diagnostic');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) async {
          await ad.dispose(); // Dispose failed ad
          final errorDesc = _getAdErrorDescription(error.code);
          log('❌ [BANNER] Google failed! Code: ${error.code} ($errorDesc) Message: ${error.message}', name: 'BannerAd-Diagnostic');
          emit(BannerAdState.failure);

          if (error.code == 3 && _bannerRetryCount < _maxRetryCount) {
            final delay = Duration(seconds: min(2 << _bannerRetryCount, 10));
            _bannerRetryCount++;

            log('⏳ [BANNER] Retrying Google in ${delay.inSeconds}s (attempt $_bannerRetryCount/$_maxRetryCount)', name: 'BannerAd-Diagnostic');
            await Future<void>.delayed(delay);
            await _createGoogleBannerAd(context); // Retry recursively
          } else {
            log('🛑 [BANNER] Stopped retrying Google after $_bannerRetryCount attempts. Last error: ${error.message}', name: 'BannerAd-Diagnostic');
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
    log('🔄 [BANNER] Creating Unity banner | Placement: $placementName', name: 'BannerAd-Diagnostic');

    _unityBannerAd = UnityBannerAd(
      placementId: placementName,
      onLoad: (_) async {
        _bannerRetryCount = 0; // Reset
        
        // Track impression quality
        await AdImpressionQualityTracker.recordImpression(_bannerAdId);
        
        // Record ad load time for performance monitoring
        final loadDuration = DateTime.now().millisecondsSinceEpoch - startTime;
        await BannerVisibilityTracker.recordAdLoadTime(_bannerAdId, loadDuration);
        
        log('✅ [BANNER] Unity loaded! Duration: ${loadDuration}ms', name: 'BannerAd-Diagnostic');
        emit(BannerAdState.loaded);
      },
      onFailed: (placementId, error, message) async {
        log('❌ [BANNER] Unity failed! Placement: $placementId Error: $error Message: $message', name: 'BannerAd-Diagnostic');
        emit(BannerAdState.failure);

        if (_bannerRetryCount < _maxRetryCount) {
          final delay = Duration(seconds: min(2 << _bannerRetryCount, 10));
          _bannerRetryCount++;

          log('⏳ [BANNER] Retrying Unity in ${delay.inSeconds}s (attempt $_bannerRetryCount/$_maxRetryCount)', name: 'BannerAd-Diagnostic');
          await Future<void>.delayed(delay);
          _createUnityBannerAd(); // Retry
        } else {
          log('🛑 [BANNER] Stopped retrying Unity after $_bannerRetryCount attempts.', name: 'BannerAd-Diagnostic');
        }
      },
    );
  }

  void initBannerAd(BuildContext context) {
    final config = context.read<SystemConfigCubit>();
    final showAds =
        config.isAdsEnable && !context.read<UserDetailsCubit>().removeAds();

    if (!showAds) {
      log('⏭️ [BANNER] Init skipped (ads disabled=${!config.isAdsEnable} premium=${context.read<UserDetailsCubit>().removeAds()})', name: 'BannerAd-Diagnostic');
      return;
    }

    // Record when banner becomes visible - lazy loading
    BannerVisibilityTracker.recordBannerVisible(_bannerAdId);
    
    // Only load ads if app is in resumed state (visible to user)
    final isScreenVisible = context.mounted && BannerVisibilityTracker.isScreenVisible(context);
    final adNetwork = config.adsType.toString().split('.').last;
    log('📊 [BANNER] Init called | Network: $adNetwork | ScreenVisible: $isScreenVisible', name: 'BannerAd-Diagnostic');
    
    if (isScreenVisible) {
      _loadBannerAd(context);
    } else {
      // Defer loading until later when screen might be visible
      log('⏸️ [BANNER] DEFERRED LOAD - Screen not visible (lifecycle check failed - may block impressions)', name: 'BannerAd-Diagnostic');
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
      log('⏸️ [BANNER] DELAYED LOAD - Not visible long enough (recursive retry in 500ms)', name: 'BannerAd-Diagnostic');
      Future.delayed(Duration(milliseconds: 500), () => _loadBannerAd(context));
      return;
    }

    log('🚀 [BANNER] _loadBannerAd proceeding with network: ${config.adsType}', name: 'BannerAd-Diagnostic');
    
    if (config.adsType == AdType.admob) {
      _createGoogleBannerAd(context);
    } else if (config.adsType == AdType.unity) {
      _createUnityBannerAd();
    } else if (config.adsType == AdType.ironSource) {
      final bannerId = config.ironSourceBannerId;
      if (bannerId.isNotEmpty) {
        log('✅ [BANNER] IronSource ID configured: $bannerId', name: 'BannerAd-Diagnostic');
        emit(BannerAdState.loaded);
      } else {
        log('❌ [BANNER] IronSource ID NOT configured', name: 'BannerAd-Diagnostic');
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

  String _getAdErrorDescription(int errorCode) {
    switch (errorCode) {
      case 0:
        return 'ERROR_CODE_INTERNAL_ERROR';
      case 1:
        return 'ERROR_CODE_INVALID_REQUEST';
      case 2:
        return 'ERROR_CODE_NETWORK_ERROR';
      case 3:
        return 'ERROR_CODE_NO_FILL (no ads available - check budget/targeting)';
      case 4:
        return 'ERROR_CODE_REQUEST_ID_MISMATCH';
      default:
        return 'UNKNOWN_ERROR_$errorCode';
    }
  }

  @override
  Future<void> close() async {
    await _googleBannerAd?.dispose();
    // Clear visibility tracking
    await BannerVisibilityTracker.clearBannerVisibility(_bannerAdId);
    return super.close();
  }
}
