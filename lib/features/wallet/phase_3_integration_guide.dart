/// Phase 3 Integration Guide
/// This file contains integration points and helpers for Phase 3 monetization features
/// Reference this file to understand where to add the monetization calls in existing screens

import 'dart:io';
import 'package:flutterquiz/features/wallet/repos/monetization_remote_data_source.dart';
import 'package:flutterquiz/features/wallet/cubit/monetization_cubit.dart';

/// INTEGRATION POINTS FOR PHASE 3
/// ==============================
/// 
/// 1. APP STARTUP (initializeApp in lib/app/app.dart):
///    Add MonetizationCubit to MultiBlocProvider:
///    ```
///    BlocProvider<MonetizationCubit>(
///      create: (_) => MonetizationCubit(MonetizationRemoteDataSource()),
///    ),
///    ```
///
/// 2. AFTER LOGIN (in AuthCubit or login screen):
///    ```
///    // Register device to track multi-accounting
///    context.read<MonetizationCubit>().registerDevice(
///      deviceId: deviceId,  // Use device_info plugin
///      deviceType: Platform.isAndroid ? 'android' : 'ios',
///      deviceName: deviceName,
///    );
///    ```
///
/// 3. APP RESUME (in main page or app init):
///    ```
///    // Check daily streak on app open
///    context.read<MonetizationCubit>().checkDailyStreak();
///    
///    // Fetch sponsor banner for display
///    context.read<MonetizationCubit>().getSponsorBanner();
///    ```
///
/// 4. AFTER QUIZ COMPLETION:
///    ```
///    // Evaluate user risk for fraud
///    context.read<MonetizationCubit>().evaluateUserRisk(
///      actionType: 'quiz_complete',
///      metadata: {
///        'score': quizScore,
///        'time_taken': timeTaken,
///        'accuracy': accuracy,
///      },
///    );
///    ```
///
/// 5. BOOST EARNINGS POPUP (after quiz):
///    ```
///    // Show "Double Your Coins" offer
///    context.read<MonetizationCubit>().offerBoostEarnings(
///      coinsEarned: coinsFromQuiz.toString(),
///    );
///    
///    // When user clicks "Double", apply boost
///    context.read<MonetizationCubit>().applyBoostEarnings(
///      boostedCoins: boostedCoinsAmount.toString(),
///    );
///    ```
///
/// 6. BEFORE WITHDRAWAL/PAYOUT:
///    ```
///    // Check if user is eligible to withdraw
///    context.read<MonetizationCubit>().checkPayoutEligibility();
///    
///    // In the wallet screen, check eligibility state before allowing payout
///    BlocBuilder<MonetizationCubit, MonetizationState>(
///      builder: (context, state) {
///        if (state is PayoutEligibilityChecked) {
///          if (!state.eligibility.eligible) {
///            // Show ineligible message with required days
///          } else {
///            // Allow payout
///          }
///        }
///      },
///    );
///    ```
///
/// 7. HOME SCREEN - SPONSOR BANNER:
///    ```
///    BlocBuilder<MonetizationCubit, MonetizationState>(
///      builder: (context, state) {
///        if (state is SponsorBannerFetched) {
///          return GestureDetector(
///            onTap: () {
///              context.read<MonetizationCubit>().recordBannerClick(
///                bannerId: state.banner.bannerId,
///              );
///              // Open banner redirect_url
///            },
///            child: Image.network(state.banner.imageUrl),
///          );
///        }
///        return const SizedBox.shrink();
///      },
///    );
///    ```
///
/// 8. DAILY STREAK DISPLAY:
///    ```
///    BlocBuilder<MonetizationCubit, MonetizationState>(
///      builder: (context, state) {
///        if (state is DailyStreakChecked) {
///          return StreakWidget(
///            count: state.streak.streakCount,
///            maxStreak: state.streak.maxStreak,
///            coinsEarned: state.streak.coinsEarned,
///            bonusUnlocked: state.streak.bonusUnlocked,
///          );
///        }
///        return const SizedBox.shrink();
///      },
///    );
///    ```
///
/// 9. WATCH UNLOCK (in premium content screen):
///    ```
///    context.read<MonetizationCubit>().getWatchUnlockConfig();
///    
///    // Show: "Watch X ads to unlock premium content"
///    BlocBuilder<MonetizationCubit, MonetizationState>(
///      builder: (context, state) {
///        if (state is WatchUnlockConfigFetched) {
///          if (state.config.enabled) {
///            return ElevatedButton(
///              onPressed: () {
///                // Show rewarded ad
///                // On ad reward, unlock content
///              },
///              child: Text('Watch Ad (${state.config.adCountRequired} needed)'),
///            );
///          }
///        }
///        return const SizedBox.shrink();
///      },
///    );
///    ```

/// Helper function to get device info for device registration
/// Usage: String deviceId = await getDeviceId();
Future<String> getDeviceId() async {
  // TODO: Implement using device_info_plus package
  // Example:
  // DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // if (Platform.isAndroid) {
  //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //   return androidInfo.id;
  // } else if (Platform.isIOS) {
  //   IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //   return iosInfo.identifierForVendor;
  // }
  return 'unknown_device_${DateTime.now().millisecondsSinceEpoch}';
}

/// Helper function to get device type
String getDeviceType() {
  return Platform.isAndroid ? 'android' : 'ios';
}

/// Helper function to get device name
Future<String> getDeviceName() async {
  // TODO: Use device_info_plus to get actual device name
  // For now, return default
  return '${getDeviceType()}_device';
}

/// All API Response Models for reference:
/// 
/// DailyStreak:
/// {
///   "error": false,
///   "data": {
///     "streak_count": 5,
///     "coins_earned": 10,
///     "bonus_unlocked": false,
///     "max_streak": 7
///   }
/// }
///
/// DeviceRegistration:
/// {
///   "error": false,
///   "data": {
///     "status": "allowed",
///     "message": "Device registered",
///     "conflict_count": 0
///   }
/// }
///
/// FraudDetection:
/// {
///   "error": false,
///   "data": {
///     "is_suspicious": false,
///     "detections": [
///       {
///         "type": "high_accuracy",
///         "severity": "warning",
///         "reason": "User accuracy exceeds threshold"
///       }
///     ]
///   }
/// }
///
/// PayoutEligibility:
/// {
///   "error": false,
///   "data": {
///     "eligible": true,
///     "active_days": 20,
///     "required_days": 20,
///     "message": "User is eligible for payout"
///   }
/// }
///
/// SponsorBanner:
/// {
///   "error": false,
///   "data": {
///     "banner_id": "123",
///     "sponsor_name": "Nike",
///     "title": "New Collection",
///     "image_url": "https://...",
///     "redirect_url": "https://nike.com",
///     "impression_limit": 1000,
///     "total_impressions": 450,
///     "today_impressions": 50
///   }
/// }
///
/// BoostEarnings:
/// {
///   "error": false,
///   "data": {
///     "original_coins": 50,
///     "boosted_coins": 100,
///     "multiplier": 2.0,
///     "coin_difference": 50
///   }
/// }
///
/// WatchUnlockConfig:
/// {
///   "error": false,
///   "data": {
///     "enabled": true,
///     "ad_count_required": 3,
///     "message": "Watch 3 ads to unlock premium content"
///   }
/// }
