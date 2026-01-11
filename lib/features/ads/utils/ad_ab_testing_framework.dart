import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';

/// Banner size variants for A/B testing
enum BannerSizeVariant {
  adaptive,      // 320x50 or 300x250 depending on screen
  medium,        // 300x250 (medium rectangle)
  banner,        // 320x50 (standard banner)
}

/// Interstitial placement variants for A/B testing
enum InterstitialPlacementVariant {
  afterQuizResult,     // Show after quiz completes (current)
  beforeLevelSelect,   // Show before user picks next quiz
  afterTwoQuizzes,     // Show after every 2 quizzes
  randomTiming,        // Random between all above
}

/// Reward amount variants for A/B testing
enum RewardAmountVariant {
  fixed,      // Always 10 coins
  variable,   // Random 5-25 coins
  progressive, // Increases with engagement level
}

/// AdABTestingFramework manages A/B test variants and consistency
/// Ensures users are consistently assigned to test variants for reliable metrics
class AdABTestingFramework {
  static const String _variantKey = 'ab_test_variant_';
  static const String _variantAssignedKey = 'ab_test_assigned_';
  static const String _variantStartKey = 'ab_test_start_';

  /// Assign or retrieve banner size variant for this user
  /// Returns same variant consistently for the user
  static Future<BannerSizeVariant> getBannerSizeVariant() async {
    return _getOrAssignVariant<BannerSizeVariant>(
      'banner_size',
      BannerSizeVariant.values,
      BannerSizeVariant.adaptive,
    ) as FutureOr<BannerSizeVariant>;
  }

  /// Assign or retrieve interstitial placement variant for this user
  static Future<InterstitialPlacementVariant> getInterstitialPlacementVariant() async {
    return _getOrAssignVariant<InterstitialPlacementVariant>(
      'interstitial_placement',
      InterstitialPlacementVariant.values,
      InterstitialPlacementVariant.afterQuizResult,
    ) as FutureOr<InterstitialPlacementVariant>;
  }

  /// Assign or retrieve reward amount variant for this user
  static Future<RewardAmountVariant> getRewardAmountVariant() async {
    return _getOrAssignVariant<RewardAmountVariant>(
      'reward_amount',
      RewardAmountVariant.values,
      RewardAmountVariant.fixed,
    ) as FutureOr<RewardAmountVariant>;
  }

  /// Get or assign variant, ensuring consistency
  static Future<T> _getOrAssignVariant<T>(
    String variantName,
    List<T> options,
    T defaultVariant,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _variantKey + variantName;
      final assignedKey = _variantAssignedKey + variantName;

      // Check if already assigned
      final storedVariant = prefs.getString(key);
      if (storedVariant != null) {
        log('Using existing variant for $variantName: $storedVariant', name: 'ABTesting');
        return options.firstWhere(
          (e) => e.toString() == storedVariant,
          orElse: () => defaultVariant,
        );
      }

      // Assign new variant randomly, with equal distribution
      final variant = options[DateTime.now().millisecond % options.length];
      await prefs.setString(key, variant.toString());
      await prefs.setInt(assignedKey, DateTime.now().millisecondsSinceEpoch);

      log('Assigned new variant for $variantName: $variant', name: 'ABTesting');

      return variant;
    } catch (e) {
      log('Error assigning variant: $e', name: 'ABTesting');
      return defaultVariant;
    }
  }

  /// Get all active test variants for this user
  static Future<Map<String, String>> getAllVariants() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final bannerVariant = await getBannerSizeVariant();
      final placementVariant = await getInterstitialPlacementVariant();
      final rewardVariant = await getRewardAmountVariant();

      return {
        'banner_size': bannerVariant.toString(),
        'interstitial_placement': placementVariant.toString(),
        'reward_amount': rewardVariant.toString(),
      };
    } catch (e) {
      log('Error getting all variants: $e', name: 'ABTesting');
      return {};
    }
  }

  /// Calculate reward coins based on variant
  static Future<int> calculateRewardCoins({int baseReward = 10}) async {
    try {
      final variant = await getRewardAmountVariant();

      switch (variant) {
        case RewardAmountVariant.fixed:
          return baseReward;

        case RewardAmountVariant.variable:
          // Random between baseReward - 5 and baseReward + 15
          final min = (baseReward - 5).clamp(1, 100);
          final max = (baseReward + 15).clamp(1, 500);
          final random = DateTime.now().millisecond % (max - min + 1);
          return min + random;

        case RewardAmountVariant.progressive:
          // Could integrate with user engagement level in future
          // For now, same as fixed
          return baseReward;
      }
    } catch (e) {
      log('Error calculating reward: $e', name: 'ABTesting');
      return baseReward;
    }
  }

  /// Check if user should see interstitial based on placement variant
  /// Call this in placement decision points
  static Future<bool> shouldShowInterstitialAt(String placementName) async {
    try {
      final variant = await getInterstitialPlacementVariant();

      switch (variant) {
        case InterstitialPlacementVariant.afterQuizResult:
          return placementName == 'after_quiz_result';

        case InterstitialPlacementVariant.beforeLevelSelect:
          return placementName == 'before_level_select';

        case InterstitialPlacementVariant.afterTwoQuizzes:
          return placementName == 'after_two_quizzes';

        case InterstitialPlacementVariant.randomTiming:
          // Random 50% chance if called from any placement
          return DateTime.now().millisecond > 500;
      }
    } catch (e) {
      log('Error checking placement: $e', name: 'ABTesting');
      return false;
    }
  }

  /// Get banner size dimensions based on variant
  static Future<(int width, int height)> getBannerDimensions() async {
    try {
      final variant = await getBannerSizeVariant();

      switch (variant) {
        case BannerSizeVariant.adaptive:
          // Return -1 to indicate adaptive sizing
          return (-1, -1);

        case BannerSizeVariant.medium:
          return (300, 250);

        case BannerSizeVariant.banner:
          return (320, 50);
      }
    } catch (e) {
      log('Error getting banner dimensions: $e', name: 'ABTesting');
      return (-1, -1); // Default to adaptive
    }
  }

  /// Get variant assignment duration (time since assigned)
  static Future<Duration> getVariantDuration(String variantName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final assignedKey = _variantAssignedKey + variantName;

      final assignedTime = prefs.getInt(assignedKey);
      if (assignedTime == null) {
        return Duration.zero;
      }

      final duration =
          DateTime.now().millisecondsSinceEpoch - assignedTime;
      return Duration(milliseconds: duration);
    } catch (e) {
      log('Error getting variant duration: $e', name: 'ABTesting');
      return Duration.zero;
    }
  }

  /// Reset all variants (useful for testing)
  static Future<void> resetAllVariants() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove all variant assignments
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_variantKey) ||
            key.startsWith(_variantAssignedKey)) {
          await prefs.remove(key);
        }
      }

      log('All variants reset', name: 'ABTesting');
    } catch (e) {
      log('Error resetting variants: $e', name: 'ABTesting');
    }
  }
}
