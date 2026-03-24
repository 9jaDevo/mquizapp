import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Network connection types and quality levels
enum NetworkType {
  wifi, // WiFi - Best quality
  mobile4g, // 4G/LTE - Good quality
  mobile3g, // 3G/UMTS - Moderate quality
  mobile2g, // 2G/Edge - Poor quality
  unknown, // Unknown connection
  none, // No connection
}

/// NetworkConnectivityTracker monitors network conditions for ad request optimization
/// Prevents ad requests on poor networks where they're unlikely to complete
class NetworkConnectivityTracker {
  static final Connectivity _connectivity = Connectivity();

  /// Get current network connection status
  static Future<NetworkType> getCurrentNetworkType() async {
    try {
      final results = await _connectivity.checkConnectivity();

      // Handle List<ConnectivityResult>
      if (results.isEmpty) {
        log('🔴 Network: None (offline)', name: 'NetworkTracker');
        return NetworkType.none;
      }

      // Check first result (devices typically return single result)
      final result = results.first;

      switch (result) {
        case ConnectivityResult.wifi:
          log('📡 Network: WiFi', name: 'NetworkTracker');
          return NetworkType.wifi;
        
        case ConnectivityResult.mobile:
          // Note: Can't detect 2G vs 3G vs 4G on Flutter without platform channels
          // Default to 4G assumption for mobile (most devices are 4G+)
          log('📱 Network: Mobile (assuming 4G)', name: 'NetworkTracker');
          return NetworkType.mobile4g;
        
        case ConnectivityResult.none:
          log('🔴 Network: None (offline)', name: 'NetworkTracker');
          return NetworkType.none;
        
        default:
          log('❓ Network: Unknown', name: 'NetworkTracker');
          return NetworkType.unknown;
      }
    } catch (e) {
      log('Error checking network type: $e', name: 'NetworkTracker');
      return NetworkType.unknown;
    }
  }

  /// Check if network is suitable for ad requests
  /// Returns false for offline or very slow networks (e.g., 2G)
  static Future<bool> isNetworkSuitableForAdRequest() async {
    final networkType = await getCurrentNetworkType();

    // Block ad requests on offline or 2G networks
    if (networkType == NetworkType.none || networkType == NetworkType.mobile2g) {
      log('🛑 Ad request blocked - unsuitable network: ${networkType.name}', name: 'NetworkTracker');
      return false;
    }

    return true;
  }

  /// Get minimum visibility window (ms) based on network type
  /// Slower networks need longer to complete ad load
  static Future<int> getMinimumVisibilityWindowMs() async {
    final networkType = await getCurrentNetworkType();

    switch (networkType) {
      case NetworkType.wifi:
        return 500; // Fast - minimal wait needed
      
      case NetworkType.mobile4g:
        return 1000; // Good - reasonable wait
      
      case NetworkType.mobile3g:
        return 2000; // Moderate - extended wait
      
      case NetworkType.mobile2g:
      case NetworkType.none:
      case NetworkType.unknown:
        return 3000; // Very conservative for poor/unknown networks
    }
  }

  /// Check if should defer ad load based on network quality
  /// Used in Nepal/slow network regions to prevent timeout failures
  static Future<bool> shouldDeferAdLoad(String countryCode) async {
    final networkType = await getCurrentNetworkType();

    // Defer on poor networks or in Nepal specifically (known to have mixed connectivity)
    if (countryCode.toUpperCase() == 'NP' && networkType == NetworkType.mobile3g) {
      log('⏸️ Deferring ad load - Nepal + 3G network', name: 'NetworkTracker');
      return true;
    }

    if (networkType == NetworkType.mobile2g || networkType == NetworkType.none) {
      log('⏸️ Deferring ad load - Poor network: ${networkType.name}', name: 'NetworkTracker');
      return true;
    }

    return false;
  }
}
