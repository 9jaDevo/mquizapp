# Phase 3: Flutter App Integration - Complete Implementation Guide

## Overview
Phase 3 integrates all 9 monetization API endpoints into the Flutter app. This includes:
- Daily streak system
- Device registration (fraud prevention)
- Fraud detection evaluation
- Payout eligibility checking
- Sponsor banner display
- Boost earnings (double coins)
- Watch unlock premium feature

## Files Created in Phase 3

### 1. API Integration Layer
- **monetization_remote_data_source.dart** - HTTP calls to all 9 API endpoints
- **monetization_models.dart** - Data models for all features
- **monetization_cubit.dart** - State management with BLoC pattern
- **monetization_state.dart** - All state classes

### 2. Constants Updated
- **api_endpoints_constants.dart** - Added 9 endpoint URLs
- **api_body_parameter_labels.dart** - Added parameter labels

### 3. Documentation
- **phase_3_integration_guide.dart** - Code comments showing exact integration points

## Implementation Steps

### Step 1: Add MonetizationCubit to App (15 minutes)

**File:** `lib/app/app.dart`

Add to MultiBlocProvider:
```dart
BlocProvider<MonetizationCubit>(
  create: (_) => MonetizationCubit(MonetizationRemoteDataSource()),
),
```

Location: After `BlocProvider<ExamCubit>` and before the closing bracket of `providers` list.

### Step 2: Device Registration After Login (20 minutes)

**File:** `lib/features/auth/cubits/auth_cubit.dart` OR login screen

Add this to the `updateAuthDetails` method or after successful login:

```dart
// After user successfully logs in
Future<void> _registerDevice() async {
  final deviceId = await getDeviceId();
  final deviceType = getDeviceType();
  
  context.read<MonetizationCubit>().registerDevice(
    deviceId: deviceId,
    deviceType: deviceType,
    deviceName: await getDeviceName(),
  );
}
```

**Dependencies needed:**
- `device_info_plus` package - Add to pubspec.yaml:
```yaml
dependencies:
  device_info_plus: ^9.0.0
```

### Step 3: Daily Streak Check on App Resume (15 minutes)

**File:** `lib/ui/screens/home/home_page.dart` or main app screen

Add to the `initState` or `_onAppResume`:

```dart
@override
void initState() {
  super.initState();
  // Check daily streak when user opens app
  Future.delayed(const Duration(milliseconds: 500), () {
    context.read<MonetizationCubit>().checkDailyStreak();
  });
}
```

### Step 4: Sponsor Banner Display (20 minutes)

**File:** `lib/ui/screens/home/home_page.dart` or any screen

Add this widget to display sponsor banners:

```dart
BlocBuilder<MonetizationCubit, MonetizationState>(
  buildWhen: (prev, curr) => curr is SponsorBannerFetched || curr is SponsorBannerNotAvailable,
  builder: (context, state) {
    if (state is SponsorBannerFetched) {
      return GestureDetector(
        onTap: () {
          context.read<MonetizationCubit>().recordBannerClick(
            bannerId: state.banner.bannerId,
          );
          // Launch URL in browser
          // launchUrl(Uri.parse(state.banner.redirectUrl));
        },
        child: Container(
          height: 200,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: NetworkImage(state.banner.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  },
)
```

### Step 5: Daily Streak UI Widget (25 minutes)

**File:** `lib/ui/screens/home/home_page.dart`

Create a streak display widget:

```dart
BlocBuilder<MonetizationCubit, MonetizationState>(
  buildWhen: (prev, curr) => curr is DailyStreakChecked,
  builder: (context, state) {
    if (state is DailyStreakChecked) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.orange, Colors.red]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Daily Streak', style: TextStyle(color: Colors.white, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '${state.streak.streakCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Days', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                Column(
                  children: [
                    Text(
                      '${state.streak.coinsEarned}',
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('Coins', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
                if (state.streak.bonusUnlocked)
                  Column(
                    children: [
                      const Text('🎁', style: TextStyle(fontSize: 28)),
                      const Text('Bonus!', style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
              ],
            ),
            if (state.streak.streakCount < state.streak.maxStreak)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  'Max Streak: ${state.streak.maxStreak}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  },
)
```

### Step 6: Quiz Completion - Boost Earnings (30 minutes)

**File:** `lib/features/quiz/screen/quiz_screen.dart` or result screen

After quiz is completed and coins are awarded:

```dart
// Show boost earnings offer
void _showBoostEarningsPopup(BuildContext context, int coinsEarned) {
  context.read<MonetizationCubit>().offerBoostEarnings(
    coinsEarned: coinsEarned.toString(),
  );
  
  showDialog(
    context: context,
    builder: (context) => BlocBuilder<MonetizationCubit, MonetizationState>(
      buildWhen: (prev, curr) => curr is BoostEarningsOffered,
      builder: (context, state) {
        if (state is BoostEarningsOffered) {
          return AlertDialog(
            title: const Text('Double Your Coins! 🎉'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Earned: ${state.boost.originalCoins} coins'),
                const SizedBox(height: 16),
                Text(
                  '${state.boost.boostedCoins} coins with boost!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 8),
                Text('+${state.boost.coinDifference} bonus coins'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Skip'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<MonetizationCubit>().applyBoostEarnings(
                    boostedCoins: state.boost.boostedCoins.toString(),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Claim Boost'),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    ),
  );
}

// Call after quiz completion
_showBoostEarningsPopup(context, quizCoinsEarned);
```

### Step 7: Fraud Detection After Quiz (15 minutes)

**File:** `lib/features/quiz/screen/quiz_screen.dart`

Add fraud evaluation after quiz:

```dart
// Call after user completes quiz
context.read<MonetizationCubit>().evaluateUserRisk(
  actionType: 'quiz_complete',
  metadata: {
    'score': quizScore,
    'time_taken': timeTaken,
    'accuracy': accuracy,
    'total_questions': totalQuestions,
  },
);

// Handle fraud detection
BlocListener<MonetizationCubit, MonetizationState>(
  listenWhen: (prev, curr) => curr is UserRiskEvaluated,
  listener: (context, state) {
    if (state is UserRiskEvaluated && state.fraud.isSuspicious) {
      // Show warning to user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unusual activity detected. Your account is under review.'),
          duration: Duration(seconds: 5),
        ),
      );
    }
  },
  child: SizedBox.shrink(),
)
```

### Step 8: Payout Eligibility Check (20 minutes)

**File:** `lib/features/wallet/wallet_screen.dart`

Add eligibility check before showing payout:

```dart
@override
void initState() {
  super.initState();
  // Check payout eligibility when user opens wallet
  context.read<MonetizationCubit>().checkPayoutEligibility();
}

// Show eligibility status
BlocBuilder<MonetizationCubit, MonetizationState>(
  buildWhen: (prev, curr) => curr is PayoutEligibilityChecked,
  builder: (context, state) {
    if (state is PayoutEligibilityChecked) {
      if (!state.eligibility.eligible) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            border: Border.all(color: Colors.orange),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text('You are not eligible to withdraw yet'),
              const SizedBox(height: 8),
              Text(
                'Active days: ${state.eligibility.activeDays}/${state.eligibility.requiredDays}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text('Need ${state.eligibility.requiredDays - state.eligibility.activeDays} more active days'),
            ],
          ),
        );
      } else {
        return ElevatedButton(
          onPressed: () {
            // Show payout form
          },
          child: const Text('Withdraw Now'),
        );
      }
    }
    return const SizedBox.shrink();
  },
)
```

### Step 9: Watch Unlock Premium (20 minutes)

**File:** `lib/features/quiz/screens/premium_content_screen.dart`

Add watch-to-unlock feature:

```dart
@override
void initState() {
  super.initState();
  context.read<MonetizationCubit>().getWatchUnlockConfig();
}

// Show unlock button
BlocBuilder<MonetizationCubit, MonetizationState>(
  buildWhen: (prev, curr) => curr is WatchUnlockConfigFetched,
  builder: (context, state) {
    if (state is WatchUnlockConfigFetched && state.config.enabled) {
      return ElevatedButton.icon(
        icon: const Icon(Icons.ondemand_video),
        label: Text('Watch ${state.config.adCountRequired} ads to unlock'),
        onPressed: () {
          // Show rewarded ad
          // On ad reward, unlock content
          _unlockPremiumContent();
        },
      );
    }
    return const SizedBox.shrink();
  },
)
```

## Error Handling

All error states are captured in `MonetizationError`:

```dart
BlocListener<MonetizationCubit, MonetizationState>(
  listenWhen: (prev, curr) => curr is MonetizationError,
  listener: (context, state) {
    if (state is MonetizationError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${state.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: const SizedBox.shrink(),
)
```

## Testing the Integration

### 1. Test Device Registration
- Run app, login
- Check device registered in admin panel (Device Management)

### 2. Test Daily Streak
- Open app daily
- Verify streak increments
- Check admin panel (Daily Streak Settings)

### 3. Test Sponsor Banner
- Banner should appear on home screen
- Clicks should be logged in admin panel

### 4. Test Boost Earnings
- Complete quiz
- See boost offer popup
- Claim boost and verify coins doubled

### 5. Test Payout Eligibility
- Go to wallet before 20 active days
- See "not eligible" message
- After 20 days, button should enable

### 6. Test Fraud Detection
- Complete quiz with suspicious pattern (too high accuracy)
- Should trigger fraud detection
- Check admin panel (Fraud Detection Dashboard)

## Dependencies to Add

Add to `pubspec.yaml`:

```yaml
dependencies:
  device_info_plus: ^9.0.0
  url_launcher: ^6.0.0
```

Run:
```bash
flutter pub get
```

## Summary of Files Modified/Created

**Created:**
- lib/features/wallet/repos/monetization_remote_data_source.dart (280 LOC)
- lib/features/wallet/models/monetization_models.dart (200 LOC)
- lib/features/wallet/cubit/monetization_cubit.dart (150 LOC)
- lib/features/wallet/cubit/monetization_state.dart (180 LOC)
- lib/features/wallet/phase_3_integration_guide.dart (250 LOC)

**Modified:**
- lib/core/constants/api_endpoints_constants.dart (+9 endpoints)
- lib/core/constants/api_body_parameter_labels.dart (+8 labels)
- lib/app/app.dart (add MonetizationCubit to MultiBlocProvider)

**To be modified (integration steps):**
- lib/features/auth/cubits/auth_cubit.dart (add device registration)
- lib/ui/screens/home/home_page.dart (add streak, banner display)
- lib/features/quiz/screens/quiz_screen.dart (add boost earnings, fraud detection)
- lib/features/wallet/wallet_screen.dart (add payout eligibility check)

## Execution Timeline

- **Step 1:** 15 minutes (Add MonetizationCubit to app)
- **Step 2:** 20 minutes (Device registration after login)
- **Step 3:** 15 minutes (Daily streak check on resume)
- **Step 4:** 20 minutes (Sponsor banner display)
- **Step 5:** 25 minutes (Daily streak UI widget)
- **Step 6:** 30 minutes (Boost earnings popup)
- **Step 7:** 15 minutes (Fraud detection)
- **Step 8:** 20 minutes (Payout eligibility)
- **Step 9:** 20 minutes (Watch unlock premium)

**Total:** ~3-4 hours for complete integration

## Next Steps After Integration

1. Build and test on Android device
2. Build and test on iOS device
3. Load test with multiple users
4. Test all error scenarios
5. Prepare for App Store deployment

## Backend Admin Panel URLs

After integration, test using these admin URLs:
- Device Management: `/admin_backend/Device`
- Daily Streaks: `/admin_backend/Streak`
- Fraud Detection: `/admin_backend/Fraud`
- Sponsor Banners: `/admin_backend/Sponsors`
- Payout Eligibility: `/admin_backend/PayoutEligibility`

All settings are configurable from admin panel without code changes.
