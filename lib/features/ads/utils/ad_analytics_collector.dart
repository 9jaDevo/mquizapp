import 'dart:developer';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// eCPM estimate (effective cost per 1000 impressions)
/// This is calculated from actual ad revenue (would come from AdMob console)
class AdMetrics {
  final String variant;
  final int impressions;
  final int clicks;
  final int conversions; // Rewarded ad completions
  final double estimatedRevenue; // In USD
  final DateTime startTime;
  final DateTime lastUpdated;

  AdMetrics({
    required this.variant,
    required this.impressions,
    required this.clicks,
    required this.conversions,
    required this.estimatedRevenue,
    required this.startTime,
    required this.lastUpdated,
  });

  /// Calculate CTR (Click-Through Rate) as percentage
  double get ctr {
    if (impressions == 0) return 0.0;
    return (clicks / impressions) * 100;
  }

  /// Calculate eCPM (Effective Cost Per Mille/1000 impressions)
  double get ecpm {
    if (impressions == 0) return 0.0;
    return (estimatedRevenue / impressions) * 1000;
  }

  /// Calculate conversion rate for rewarded ads
  double get conversionRate {
    if (clicks == 0) return 0.0;
    return (conversions / clicks) * 100;
  }

  /// Duration this variant has been active
  Duration get activeDuration => DateTime.now().difference(startTime);

  Map<String, dynamic> toJson() => {
    'variant': variant,
    'impressions': impressions,
    'clicks': clicks,
    'conversions': conversions,
    'estimated_revenue': estimatedRevenue,
    'ctr_percent': ctr.toStringAsFixed(2),
    'ecpm': ecpm.toStringAsFixed(2),
    'conversion_rate': conversionRate.toStringAsFixed(2),
    'active_duration_hours': activeDuration.inHours,
    'start_time': startTime.toIso8601String(),
    'last_updated': lastUpdated.toIso8601String(),
  };
}

/// AdAnalyticsCollector tracks metrics for A/B testing
/// Measures: eCPM, CTR, fill rate, impressions, conversions per variant
class AdAnalyticsCollector {
  static const String _variantMetricsKey = 'variant_metrics_';
  static const String _dailyStatsKey = 'daily_stats_';

  /// Record an impression for tracking
  static Future<void> recordImpressionMetric(String variantName) async {
    try {
      await _incrementMetric(variantName, 'impressions');
    } catch (e) {
      log('Error recording impression metric: $e', name: 'Analytics');
    }
  }

  /// Record a click for tracking
  static Future<void> recordClickMetric(String variantName) async {
    try {
      await _incrementMetric(variantName, 'clicks');
    } catch (e) {
      log('Error recording click metric: $e', name: 'Analytics');
    }
  }

  /// Record a conversion (completed rewarded ad)
  static Future<void> recordConversionMetric(String variantName) async {
    try {
      await _incrementMetric(variantName, 'conversions');
    } catch (e) {
      log('Error recording conversion metric: $e', name: 'Analytics');
    }
  }

  /// Update estimated revenue for a variant
  /// Call this periodically with AdMob console data
  static Future<void> updateRevenueEstimate(
    String variantName,
    double revenueUSD,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _variantMetricsKey + variantName;

      final existing = await _getMetricData(variantName);
      existing['revenue'] = revenueUSD;
      existing['last_updated'] = DateTime.now().toIso8601String();

      await prefs.setString(key, jsonEncode(existing));

      log('Revenue updated for $variantName: \$$revenueUSD', name: 'Analytics');
    } catch (e) {
      log('Error updating revenue: $e', name: 'Analytics');
    }
  }

  /// Get current metrics for a variant
  static Future<AdMetrics?> getVariantMetrics(String variantName) async {
    try {
      final data = await _getMetricData(variantName);

      if (data.isEmpty) return null;

      return AdMetrics(
        variant: variantName,
        impressions: (data['impressions'] as num?)?.toInt() ?? 0,
        clicks: (data['clicks'] as num?)?.toInt() ?? 0,
        conversions: (data['conversions'] as num?)?.toInt() ?? 0,
        estimatedRevenue: (data['revenue'] as num?)?.toDouble() ?? 0.0,
        startTime: DateTime.parse(
          (data['start_time'] as String?) ?? DateTime.now().toIso8601String(),
        ),
        lastUpdated: DateTime.parse(
          (data['last_updated'] as String?) ?? DateTime.now().toIso8601String(),
        ),
      );
    } catch (e) {
      log('Error getting variant metrics: $e', name: 'Analytics');
      return null;
    }
  }

  /// Get metrics for all variants for comparison
  static Future<List<AdMetrics>> getAllVariantMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      final allMetrics = <AdMetrics>[];

      for (final key in keys) {
        if (key.startsWith(_variantMetricsKey)) {
          final variantName = key.replaceFirst(_variantMetricsKey, '');
          final metrics = await getVariantMetrics(variantName);
          if (metrics != null) {
            allMetrics.add(metrics);
          }
        }
      }

      // Sort by eCPM (highest first)
      allMetrics.sort((a, b) => b.ecpm.compareTo(a.ecpm));

      return allMetrics;
    } catch (e) {
      log('Error getting all metrics: $e', name: 'Analytics');
      return [];
    }
  }

  /// Compare performance of two variants
  static Future<String> compareVariants(String variant1, String variant2) async {
    try {
      final metrics1 = await getVariantMetrics(variant1);
      final metrics2 = await getVariantMetrics(variant2);

      if (metrics1 == null || metrics2 == null) {
        return 'Insufficient data for comparison';
      }

      final ecpmDiff = metrics1.ecpm - metrics2.ecpm;
      final ctrDiff = metrics1.ctr - metrics2.ctr;
      final conversionDiff = metrics1.conversionRate - metrics2.conversionRate;

      final winner = ecpmDiff > 0 ? variant1 : variant2;
      final ecpmPercent = ((ecpmDiff.abs() / metrics2.ecpm) * 100).toStringAsFixed(1);

      return '''
A/B Test Comparison:
$variant1 vs $variant2

eCPM:
  $variant1: \$${metrics1.ecpm.toStringAsFixed(2)}
  $variant2: \$${metrics2.ecpm.toStringAsFixed(2)}
  Winner: $winner (+${ecpmPercent}%)

CTR:
  $variant1: ${metrics1.ctr.toStringAsFixed(2)}%
  $variant2: ${metrics2.ctr.toStringAsFixed(2)}%
  Diff: ${ctrDiff > 0 ? '+' : ''}${ctrDiff.toStringAsFixed(2)}%

Conversion Rate:
  $variant1: ${metrics1.conversionRate.toStringAsFixed(2)}%
  $variant2: ${metrics2.conversionRate.toStringAsFixed(2)}%
  Diff: ${conversionDiff > 0 ? '+' : ''}${conversionDiff.toStringAsFixed(2)}%

Impressions:
  $variant1: ${metrics1.impressions}
  $variant2: ${metrics2.impressions}
''';
    } catch (e) {
      log('Error comparing variants: $e', name: 'Analytics');
      return 'Error comparing variants';
    }
  }

  /// Generate daily statistics summary
  static Future<String> generateDailyReport() async {
    try {
      final allMetrics = await getAllVariantMetrics();

      if (allMetrics.isEmpty) {
        return 'No metrics available';
      }

      final totalImpressions = allMetrics.fold<int>(0, (sum, m) => sum + m.impressions);
      final totalClicks = allMetrics.fold<int>(0, (sum, m) => sum + m.clicks);
      final totalRevenue = allMetrics.fold<double>(0.0, (sum, m) => sum + m.estimatedRevenue);
      final avgCTR = totalImpressions > 0 ? (totalClicks / totalImpressions) * 100 : 0.0;
      final avgECPM = totalImpressions > 0 ? (totalRevenue / totalImpressions) * 1000 : 0.0;

      var report = '''
=== Daily Ad Analytics Report ===

Overall Metrics:
  Total Impressions: $totalImpressions
  Total Clicks: $totalClicks
  CTR: ${avgCTR.toStringAsFixed(2)}%
  Estimated Revenue: \$${totalRevenue.toStringAsFixed(2)}
  Avg eCPM: \$${avgECPM.toStringAsFixed(2)}

Variant Performance:
''';

      for (int i = 0; i < allMetrics.length; i++) {
        final m = allMetrics[i];
        report += '''
${i + 1}. ${m.variant}
   Impressions: ${m.impressions} | Clicks: ${m.clicks} | Conversions: ${m.conversions}
   CTR: ${m.ctr.toStringAsFixed(2)}% | eCPM: \$${m.ecpm.toStringAsFixed(2)}
   Revenue: \$${m.estimatedRevenue.toStringAsFixed(2)} | Active: ${m.activeDuration.inHours}h
''';
      }

      return report;
    } catch (e) {
      log('Error generating report: $e', name: 'Analytics');
      return 'Error generating report';
    }
  }

  /// Clear all metrics (useful for testing)
  static Future<void> resetAllMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();

      for (final key in keys) {
        if (key.startsWith(_variantMetricsKey) ||
            key.startsWith(_dailyStatsKey)) {
          await prefs.remove(key);
        }
      }

      log('All metrics reset', name: 'Analytics');
    } catch (e) {
      log('Error resetting metrics: $e', name: 'Analytics');
    }
  }

  // ============ Private Methods ============

  /// Increment a metric counter
  static Future<void> _incrementMetric(String variantName, String metric) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _variantMetricsKey + variantName;

      final existing = await _getMetricData(variantName);
      existing[metric] = (existing[metric] ?? 0) + 1;
      existing['last_updated'] = DateTime.now().toIso8601String();

      if (!existing.containsKey('start_time')) {
        existing['start_time'] = DateTime.now().toIso8601String();
      }

      await prefs.setString(key, jsonEncode(existing));
    } catch (e) {
      log('Error incrementing metric: $e', name: 'Analytics');
    }
  }

  /// Get metric data for a variant
  static Future<Map<String, dynamic>> _getMetricData(String variantName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _variantMetricsKey + variantName;

      final data = prefs.getString(key);
      if (data == null) return {};

      return Map<String, dynamic>.from(jsonDecode(data) as Map);
    } catch (e) {
      log('Error getting metric data: $e', name: 'Analytics');
      return {};
    }
  }
}
