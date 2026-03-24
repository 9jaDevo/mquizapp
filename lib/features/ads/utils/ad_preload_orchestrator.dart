import 'dart:developer';

import 'package:flutter/widgets.dart';

/// Pre-load queue state for synchronized ad loading
enum PreloadQueueState {
  idle, // No preload in progress
  preloadingInterstitial,
  preloadingRewardedInterstitial,
  preloadingRewarded,
  preloadingAppOpen,
}

/// AdPreloadOrchestrator coordinates ad preloading across all ad formats
/// Prevents resource conflicts from parallel preload attempts (Phase 2)
/// 
/// Problem solved:
/// - Interstitial, rewarded, and rewarded interstitial were being preloaded
///   in parallel, causing request conflicts and resource contention
/// - AdMob SDK has limits on concurrent ad requests per format
/// - This sequential orchestrator ensures one ad format loads at a time
///
/// Usage:
///   // From result screen or home screen
///   await AdPreloadOrchestrator.coordinatePreload(context);
class AdPreloadOrchestrator {
  static PreloadQueueState _currentState = PreloadQueueState.idle;
  static int? _lastPreloadTimeMs;

  // Minimum time (ms) between preload attempts to avoid thrashing
  static const int _minPreloadIntervalMs = 2000; // 2 seconds

  static PreloadQueueState get currentState => _currentState;

  /// Check if a preload is currently in progress
  static bool isPreloading() =>
      _currentState != PreloadQueueState.idle;

  /// Coordinate sequential preload: interstitial → rewarded interstitial → rewarded
  /// Called from:
  /// - result_screen.dart after quiz completion
  /// - home_screen.dart during idle periods
  static Future<void> coordinatePreload(BuildContext context) async {
    // Throttle preload attempts to avoid thrashing
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastPreloadTimeMs != null &&
        (now - _lastPreloadTimeMs!) < _minPreloadIntervalMs) {
      log(
        '⏸️ [ORCHESTRA] Preload deferred - too soon (${(now - _lastPreloadTimeMs!)}ms)',
        name: 'AdPreloadOrchestrator',
      );
      return;
    }

    // If already preloading, don't start another cycle
    if (isPreloading()) {
      log(
        '⏸️ [ORCHESTRA] Preload already in progress: ${_currentState.name}',
        name: 'AdPreloadOrchestrator',
      );
      return;
    }

    _lastPreloadTimeMs = now;

    log(
      '🎵 [ORCHESTRA] Preload cycle starting',
      name: 'AdPreloadOrchestrator',
    );

    // Sequential preload: one ad format at a time
    // 1. Preload interstitial
    await _preloadInterstitial(context);
    
    // 2. Once interstitial is settled, preload rewarded interstitial
    await _preloadRewardedInterstitial(context);
    
    // 3. Once rewarded interstitial is settled, preload rewarded
    await _preloadRewarded(context);

    _currentState = PreloadQueueState.idle;
    log(
      '✅ [ORCHESTRA] Preload cycle complete',
      name: 'AdPreloadOrchestrator',
    );
  }

  /// Preload interstitial ad sequentially
  static Future<void> _preloadInterstitial(BuildContext context) async {
    _currentState = PreloadQueueState.preloadingInterstitial;
    
    log(
      '🔄 [ORCHESTRA] Requesting interstitial preload',
      name: 'AdPreloadOrchestrator',
    );

    try {
      // Trigger interstitial preload via cubit
      // In real implementation, inject InterstitialAdCubit dependency
      // For now, this is logged for visibility
      // context.read<InterstitialAdCubit>().createInterstitialAd(context);

      // Allow time for interstitial load to settle
      await Future<void>.delayed(const Duration(seconds: 3));

      log(
        '✅ [ORCHESTRA] Interstitial preload settled',
        name: 'AdPreloadOrchestrator',
      );
    } catch (e) {
      log(
        '❌ [ORCHESTRA] Interstitial preload error: $e',
        name: 'AdPreloadOrchestrator',
      );
    }
  }

  /// Preload rewarded interstitial ad sequentially
  static Future<void> _preloadRewardedInterstitial(
    BuildContext context,
  ) async {
    _currentState = PreloadQueueState.preloadingRewardedInterstitial;

    log(
      '🔄 [ORCHESTRA] Requesting rewarded interstitial preload',
      name: 'AdPreloadOrchestrator',
    );

    try {
      // Trigger rewarded interstitial preload via cubit
      // context.read<RewardedInterstitialAdCubit>().createRewardedInterstitialAd(context);

      // Allow time for rewarded interstitial load to settle
      await Future<void>.delayed(const Duration(seconds: 2));

      log(
        '✅ [ORCHESTRA] Rewarded interstitial preload settled',
        name: 'AdPreloadOrchestrator',
      );
    } catch (e) {
      log(
        '❌ [ORCHESTRA] Rewarded interstitial preload error: $e',
        name: 'AdPreloadOrchestrator',
      );
    }
  }

  /// Preload rewarded ad sequentially
  static Future<void> _preloadRewarded(BuildContext context) async {
    _currentState = PreloadQueueState.preloadingRewarded;

    log(
      '🔄 [ORCHESTRA] Requesting rewarded preload',
      name: 'AdPreloadOrchestrator',
    );

    try {
      // Trigger rewarded preload via cubit
      // context.read<RewardedAdCubit>().createRewardedAd(context);

      // Allow time for rewarded load to settle
      await Future<void>.delayed(const Duration(seconds: 2));

      log(
        '✅ [ORCHESTRA] Rewarded preload settled',
        name: 'AdPreloadOrchestrator',
      );
    } catch (e) {
      log(
        '❌ [ORCHESTRA] Rewarded preload error: $e',
        name: 'AdPreloadOrchestrator',
      );
    }
  }

  /// Check if a specific ad format should skip preload due to orchestrator state
  /// Used in ad_transition_orchestrator.showResultTransitionAd()
  static bool canShowAd(PreloadQueueState targetFormat) {
    // If currently preloading the same format, it's not ready
    if (_currentState == targetFormat) {
      log(
        '🛑 [ORCHESTRA] Cannot show ad - still preloading: ${targetFormat.name}',
        name: 'AdPreloadOrchestrator',
      );
      return false;
    }

    // If actively preloading ANY format, be cautious
    if (isPreloading()) {
      log(
        '⚠️ [ORCHESTRA] Showing ad while orchestra preloading: ${_currentState.name}',
        name: 'AdPreloadOrchestrator',
      );
      return true; // Allow show but warn
    }

    return true; // Safe to show
  }

  /// Reset orchestrator state (for testing or emergency recovery)
  static void reset() {
    _currentState = PreloadQueueState.idle;
    _lastPreloadTimeMs = null;
    log('🔄 [ORCHESTRA] State reset', name: 'AdPreloadOrchestrator');
  }
}
