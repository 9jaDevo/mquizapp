import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks impression quality and detects suspicious click patterns
/// that might indicate invalid traffic or ad fraud.
class AdImpressionQualityTracker {
  static const String _impressionKey = 'ad_impression_';
  static const String _clickPatternKey = 'ad_click_pattern_';
  static const String _qualityScoreKey = 'ad_quality_score_';
  
  // Quality rules
  static const int _minClickIntervalMs = 2000; // Min 2 seconds between clicks
  static const int _maxClicksPerMinute = 10;   // Max 10 clicks per minute
  static const int _maxClicksPerSession = 50;  // Max 50 clicks per session

  /// Record an impression (ad displayed)
  static Future<void> recordImpression(String adId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _impressionKey + adId;
      
      final impressions = prefs.getInt(key) ?? 0;
      await prefs.setInt(key, impressions + 1);
      
      log('✅ [IMPRESSION] Recorded for $adId (total: ${impressions + 1})', name: 'AdQuality-Diagnostic');
    } catch (e) {
      log('❌ [IMPRESSION] Error recording: $e', name: 'AdQuality-Diagnostic');
    }
  }

  /// Record a click and check if it's suspicious
  /// Returns quality score: 1.0 = excellent, 0.0 = suspicious/invalid
  static Future<double> recordClickAndGetQuality(String adId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patternKey = _clickPatternKey + adId;
      
      final currentTime = DateTime.now().millisecondsSinceEpoch;
      
      // Get previous clicks
      final patternStr = prefs.getString(patternKey) ?? '';
      final clickTimes = List<int>.from(
        patternStr
        .split(',')
        .where((String e) => e.isNotEmpty)
        .map((String e) => int.tryParse(e) ?? 0)
        .toList(),
      );
      
      // Check for suspicious patterns
      double qualityScore = 1.0;
      
      // Rule 1: Check minimum interval between clicks
      if (clickTimes.isNotEmpty) {
        final lastClickTime = clickTimes.last;
        final timeSinceLastClick = currentTime - lastClickTime;
        
        if (timeSinceLastClick < _minClickIntervalMs) {
          log('⚠️ Suspicious: Click too soon after last (${timeSinceLastClick}ms)', name: 'AdQuality');
          qualityScore *= 0.3; // Reduce score significantly
        }
      }
      
      // Rule 2: Check clicks per minute
      final oneMinuteAgo = currentTime - 60000;
      final recentClicks = clickTimes.where((t) => t > oneMinuteAgo).length;
      
      if (recentClicks > _maxClicksPerMinute) {
        log('⚠️ Suspicious: Too many clicks per minute ($recentClicks > $_maxClicksPerMinute)', name: 'AdQuality');
        qualityScore *= 0.2; // Heavily penalize
      }
      
      // Rule 3: Check total clicks in session
      if (clickTimes.length >= _maxClicksPerSession) {
        log('⚠️ Suspicious: Click session limit exceeded (${clickTimes.length} >= $_maxClicksPerSession)', name: 'AdQuality');
        qualityScore *= 0.1; // Heavily penalize
      }
      
      // Add current click to pattern, keep last 100 clicks
      clickTimes.add(currentTime);
      if (clickTimes.length > 100) {
        clickTimes.removeAt(0);
      }
      
      await prefs.setString(patternKey, clickTimes.join(','));
      
      // Store quality score
      final scoreKey = _qualityScoreKey + adId;
      await prefs.setDouble(scoreKey, qualityScore);
      
      log('Click recorded for $adId (quality: ${(qualityScore * 100).toStringAsFixed(1)}%)', name: 'AdQuality');
      
      return qualityScore;
    } catch (e) {
      log('Error recording click: $e', name: 'AdQuality');
      return 0.5; // Return neutral score on error
    }
  }

  /// Get impression count for an ad
  static Future<int> getImpressionCount(String adId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_impressionKey + adId) ?? 0;
    } catch (e) {
      log('Error getting impression count: $e', name: 'AdQuality');
      return 0;
    }
  }

  /// Get click count for an ad
  static Future<int> getClickCount(String adId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final patternKey = _clickPatternKey + adId;
      final patternStr = prefs.getString(patternKey) ?? '';
      
      final clickTimes = List<int>.from(
        patternStr
        .split(',')
        .where((String e) => e.isNotEmpty)
        .map((String e) => int.tryParse(e) ?? 0)
        .toList(),
      );
      
      return clickTimes.length;
    } catch (e) {
      log('Error getting click count: $e', name: 'AdQuality');
      return 0;
    }
  }

  /// Get current quality score for an ad (0.0 - 1.0)
  static Future<double> getQualityScore(String adId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoreKey = _qualityScoreKey + adId;
      return prefs.getDouble(scoreKey) ?? 1.0;
    } catch (e) {
      log('Error getting quality score: $e', name: 'AdQuality');
      return 1.0;
    }
  }

  /// Get CTR (Click-Through Rate) as percentage
  static Future<double> getClickThroughRate(String adId) async {
    try {
      final impressions = await getImpressionCount(adId);
      final clicks = await getClickCount(adId);
      
      if (impressions == 0) return 0.0;
      
      final ctr = (clicks / impressions) * 100;
      return ctr;
    } catch (e) {
      log('Error calculating CTR: $e', name: 'AdQuality');
      return 0.0;
    }
  }

  /// Reset all metrics for an ad (useful for testing)
  static Future<void> resetMetrics(String adId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_impressionKey + adId);
      await prefs.remove(_clickPatternKey + adId);
      await prefs.remove(_qualityScoreKey + adId);
      
      log('Metrics reset for $adId', name: 'AdQuality');
    } catch (e) {
      log('Error resetting metrics: $e', name: 'AdQuality');
    }
  }
}
