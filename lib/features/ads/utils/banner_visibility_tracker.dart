import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks visibility state of banner ads to implement lazy loading.
/// Only loads banners when screen becomes visible to improve performance.
class BannerVisibilityTracker {
  static const String _visibilityKey = 'banner_visible_';
  static const String _loadTimeKey = 'banner_load_time_';
  static const Duration _minVisibilityDuration = Duration(milliseconds: 500);

  /// Check if screen is currently visible to user
  static bool isScreenVisible(BuildContext context) {
    // Navigator.of(context).context is the current route context
    // If app is in foreground and this widget is mounted, screen is visible
    return WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
  }

  /// Record when banner becomes visible
  static Future<void> recordBannerVisible(String bannerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_visibilityKey + bannerId, DateTime.now().millisecondsSinceEpoch);
      log('Banner visibility recorded: $bannerId', name: 'BannerVisibility');
    } catch (e) {
      log('Error recording banner visibility: $e', name: 'BannerVisibility');
    }
  }

  /// Get how long banner has been visible (in milliseconds)
  static Future<int> getVisibilityDuration(String bannerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final visibleTime = prefs.getInt(_visibilityKey + bannerId);
      if (visibleTime == null) return 0;
      return DateTime.now().millisecondsSinceEpoch - visibleTime;
    } catch (e) {
      log('Error getting visibility duration: $e', name: 'BannerVisibility');
      return 0;
    }
  }

  /// Check if banner has been visible long enough to load ads
  static Future<bool> shouldLoadBanner(String bannerId) async {
    final duration = await getVisibilityDuration(bannerId);
    final shouldLoad = duration >= _minVisibilityDuration.inMilliseconds;
    
    if (!shouldLoad) {
      log('Banner $bannerId not visible long enough ($duration ms < ${_minVisibilityDuration.inMilliseconds} ms)',
          name: 'BannerVisibility');
    }
    
    return shouldLoad;
  }

  /// Clear visibility tracking for banner (called on disposal)
  static Future<void> clearBannerVisibility(String bannerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_visibilityKey + bannerId);
      await prefs.remove(_loadTimeKey + bannerId);
      log('Banner visibility cleared: $bannerId', name: 'BannerVisibility');
    } catch (e) {
      log('Error clearing banner visibility: $e', name: 'BannerVisibility');
    }
  }

  /// Record actual ad load time for performance tracking
  static Future<void> recordAdLoadTime(String bannerId, int durationMs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _loadTimeKey + bannerId;
      
      // Store as JSON array to track multiple load times
      final existingStr = prefs.getString(key) ?? '';
      final times = List<int>.from(
        existingStr
            .split(',')
            .where((String e) => e.isNotEmpty)
            .map((String e) => int.tryParse(e) ?? 0)
            .toList(),
      );
      times.add(durationMs);
      
      // Keep only last 10 load times to avoid bloat
      if (times.length > 10) {
        times.removeAt(0);
      }
      
      await prefs.setString(key, times.join(','));
      log('Ad load time recorded for $bannerId: ${durationMs}ms', name: 'BannerVisibility');
    } catch (e) {
      log('Error recording ad load time: $e', name: 'BannerVisibility');
    }
  }

  /// Get average ad load time for a banner
  static Future<double> getAverageLoadTime(String bannerId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _loadTimeKey + bannerId;
      final existingStr = prefs.getString(key) ?? '';
      
      final times = List<int>.from(
        existingStr
            .split(',')
            .where((String e) => e.isNotEmpty)
            .map((String e) => int.tryParse(e) ?? 0)
            .toList(),
      );
      
      if (times.isEmpty) return 0.0;
      return times.reduce((a, b) => a + b) / times.length;
    } catch (e) {
      log('Error getting average load time: $e', name: 'BannerVisibility');
      return 0.0;
    }
  }
}
