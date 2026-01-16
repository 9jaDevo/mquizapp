# 📍 Ad Placement Guide - Where Users See Ads

## Overview
Your mQuiz app now has **5 ad formats** strategically placed throughout the user journey:

---

## 🎯 1. App Open Ads (NEW)

### **When Users See It:**
- **App Launch**: When user first opens the app
- **App Resume**: When user returns to app from background (after 4+ hours)

### **Implementation Location:**
- **File**: [home_screen.dart](lib/ui/screens/home/home_screen.dart)
- **Line 115**: `context.read<AppOpenAdCubit>().loadAppOpenAd(context)` - Loads at startup
- **Line 404**: `context.read<AppOpenAdCubit>().showAppOpenAdIfAvailable()` - Shows on resume

### **User Experience:**
```
User Flow:
┌─────────────────┐
│ User taps app   │
│ icon            │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ App Open Ad     │ ← Full screen ad
│ (4-10 seconds)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Home Screen     │
└─────────────────┘
```

### **Frequency Capping:**
- Shows max **1 time per 4 hours**
- Max **3 times per day**
- Auto-skipped if ad is stale (>4 hours old)

### **Revenue:**
- **eCPM**: $8-15
- **Expected**: ~$0.024-0.045/day (at 5 DAU)

---

## 🎯 2. Banner Ads (EXISTING)

### **When Users See It:**
Displayed at the **bottom of screens** continuously while browsing:

### **Visible On These Screens:**
1. **Category Screen** ([category_screen.dart](lib/ui/screens/quiz/category_screen.dart) - Line 77)
   - When selecting quiz categories
   
2. **Subcategory Screen** ([subcategory_screen.dart](lib/ui/screens/quiz/subcategory_screen.dart) - Line 308)
   - When browsing quiz subcategories
   
3. **Subcategory & Level Screen** ([subcategory_and_level_screen.dart](lib/ui/screens/quiz/subcategory_and_level_screen.dart) - Line 75)
   - When selecting difficulty levels
   
4. **Levels Screen** ([levels_screen.dart](lib/ui/screens/quiz/levels_screen.dart) - Line 433)
   - When viewing quiz levels
   
5. **Fun & Learn Title Screen** ([fun_and_learn_title_screen.dart](lib/ui/screens/quiz/fun_and_learn_title_screen.dart) - Line 219)
   - In educational quiz section
   
6. **Exams Screen** ([exams_screen.dart](lib/ui/screens/exam/exams_screen.dart) - Line 434)
   - When browsing exam modules
   
7. **Coin History Screen** ([coin_history_screen.dart](lib/features/coin_history/screens/coin_history_screen.dart) - Line 174)
   - When viewing coin transaction history

### **User Experience:**
```
┌──────────────────────────┐
│                          │
│   Quiz Categories        │
│   Content Area           │
│                          │
│                          │
├──────────────────────────┤
│  [Banner Ad - 320x50]    │ ← Always visible at bottom
└──────────────────────────┘
```

### **Implementation:**
- **Widget**: [banner_ad_container.dart](lib/features/ads/widgets/banner_ad_container.dart)
- **Usage**: `const BannerAdContainer()` placed at bottom of screens

### **Revenue:**
- **eCPM**: $0.25-0.50
- **Expected**: ~$0.002-0.004/day per screen (at 5 DAU)

---

## 🎯 3. Interstitial Ads (EXISTING)

### **When Users See It:**
Full-screen ads shown at **natural transition points**:

### **Triggered On:**
1. **After Quiz Completion** ([result_screen.dart](lib/ui/screens/quiz/result_screen.dart) - Line 197)
   - When user finishes a quiz and views results
   
2. **After Multi-Match** ([multi_match_result_screen.dart](lib/ui/screens/quiz/multi_match/screens/multi_match_result_screen.dart) - Line 95)
   - After completing multi-match quiz
   
3. **Entering Category Selection** ([category_screen.dart](lib/ui/screens/quiz/category_screen.dart) - Line 56)
   - When navigating to category screen (with frequency cap)
   
4. **Wallet Screen** ([wallet_screen.dart](lib/features/wallet/screens/wallet_screen.dart) - Line 110)
   - Before entering wallet section

### **User Experience:**
```
User Flow:
┌─────────────────┐
│ Complete Quiz   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Interstitial Ad │ ← Full screen, 5-10 seconds
│ [Skip in 5s]    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Results Screen  │
└─────────────────┘
```

### **Frequency Capping:**
- AdMob manages frequency automatically
- App uses `AdFrequencyManager.canShowAd()` to avoid spam

### **Revenue:**
- **eCPM**: $2-4
- **Expected**: ~$0.010-0.020/day (at 5 DAU)

---

## 🎯 4. Rewarded Ads (EXISTING)

### **When Users See It:**
User **opts-in** to watch for coin rewards:

### **Triggered On:**
1. **Daily Ads** ([home_screen.dart](lib/ui/screens/home/home_screen.dart) - Line 111)
   - User taps "Watch Ad" button to earn daily coins
   
2. **Lifeline Help** ([quiz_screen.dart](lib/ui/screens/quiz/quiz_screen.dart) - Line 528)
   - During quiz when user needs help (50:50, skip question)
   
3. **Guess The Word** ([guess_the_word_question_container.dart](lib/ui/screens/quiz/widgets/guess_the_word_question_container.dart) - Line 236)
   - When user needs hints
   
4. **Battle Mode** ([random_battle_screen.dart](lib/ui/screens/battle/random_battle_screen.dart) - Line 426)
   - For extra coins in battle mode

### **User Experience:**
```
User Flow:
┌─────────────────┐
│ User taps       │
│ "Watch Ad" btn  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Rewarded Ad     │ ← 15-30 seconds
│ (Must complete) │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ +10 Coins!      │ ← Reward granted
└─────────────────┘
```

### **Reward Amount:**
- **Standard**: 10 coins per ad

### **Revenue:**
- **eCPM**: $2-4
- **Expected**: ~$0.010-0.020/day (at 5 DAU)

---

## 🎯 5. Rewarded Interstitial Ads (NEW) ⚡

### **When Users See It:**
**Currently**: Loads on home screen but NOT automatically shown
**Status**: ⚠️ **NOT YET INTEGRATED INTO USER FLOW**

### **Current Implementation:**
- **File**: [home_screen.dart](lib/ui/screens/home/home_screen.dart)
- **Line 118**: `context.read<RewardedInterstitialAdCubit>().createRewardedInterstitialAd(context)`
- **Status**: Ad is loaded but `showAd()` is never called

### **⚠️ WHERE IT SHOULD BE SHOWN:**

You need to integrate it into your app! Here are **recommended placements**:

#### **Option 1: After 2 Quizzes (Recommended)**
```dart
// In result_screen.dart after quiz completion
int _quizCount = 0;

void _onQuizComplete() async {
  _quizCount++;
  
  if (_quizCount % 2 == 0) {
    // Show rewarded interstitial every 2 quizzes
    await context.read<RewardedInterstitialAdCubit>().showAd(
      context: context,
      rewardAmount: 15, // Higher reward
      rewardCurrencyLabel: 'coins',
      onAdDismissedCallback: () {
        // Continue to results screen
        Navigator.pushNamed(context, Routes.result);
      },
    );
  }
}
```

#### **Option 2: Premium Reward Offer**
Add a button on home screen for "Watch Premium Ad for 15 Coins":

```dart
// In home_screen.dart
ElevatedButton(
  onPressed: () {
    context.read<RewardedInterstitialAdCubit>().showAd(
      context: context,
      rewardAmount: 15,
      rewardCurrencyLabel: 'coins',
      onAdDismissedCallback: () {
        // Ad completed
      },
    );
  },
  child: Text('Watch Premium Ad (+15 Coins)'),
)
```

#### **Option 3: Before Level Up**
Show when user is about to unlock new level:

```dart
// In levels_screen.dart
void _unlockLevel() async {
  // Show consent dialog first (built-in to showAd)
  await context.read<RewardedInterstitialAdCubit>().showAd(
    context: context,
    rewardAmount: 15,
    onAdDismissedCallback: () {
      // Unlock the level
      _performLevelUnlock();
    },
  );
}
```

### **User Experience (When Integrated):**
```
User Flow:
┌─────────────────────┐
│ Trigger action      │
│ (e.g., 2nd quiz)    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Consent Dialog      │ ← "Watch ad for 15 coins?"
│ [Watch] [Skip]      │
└──────────┬──────────┘
           │ (if Watch)
           ▼
┌─────────────────────┐
│ Rewarded            │ ← Full screen, 15-30 sec
│ Interstitial Ad     │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ +15 Coins!          │ ← Higher reward
└─────────────────────┘
```

### **Key Features:**
- **Built-in Consent Dialog**: User can skip before ad shows
- **Higher Reward**: 15 coins (vs 10 for standard rewarded)
- **Tracked Analytics**: Consent, impressions, conversions
- **Premium eCPM**: $3-6 (higher than regular rewarded)

### **Revenue (Once Integrated):**
- **eCPM**: $3-6
- **Expected**: ~$0.006-0.012/day (at 5 DAU, 2 impressions/day)

---

## 📊 Ad Performance Summary

| Ad Format | Location | User Trigger | Frequency | eCPM | Daily Revenue (5 DAU) |
|-----------|----------|--------------|-----------|------|-----------------------|
| **App Open** | App launch/resume | Automatic | 1-3/day | $8-15 | $0.024-0.045 |
| **Banner** | 7 screens | Continuous | Always visible | $0.25-0.50 | $0.010-0.020 |
| **Interstitial** | Quiz results, transitions | Automatic | 2-4/day | $2-4 | $0.010-0.020 |
| **Rewarded** | Buttons, lifelines | User opt-in | 1-2/day | $2-4 | $0.004-0.008 |
| **Rewarded Int.** | ⚠️ NOT YET INTEGRATED | N/A | 0/day | $3-6 | $0.000 |
| **TOTAL** | - | - | - | - | **$0.048-0.093/day** |

### **Revenue Projections:**

| Daily Active Users | Daily Revenue | Monthly Revenue | Yearly Revenue |
|-------------------|---------------|-----------------|----------------|
| **5 DAU** | $0.05-0.09 | $1.50-2.70 | **$18-33** |
| **50 DAU** | $0.50-0.90 | $15-27 | **$180-330** |
| **500 DAU** | $5-9 | $150-270 | **$1,800-3,300** |
| **5,000 DAU** | $50-90 | $1,500-2,700 | **$18,000-33,000** |

**⚠️ Note**: These projections **exclude Rewarded Interstitial** revenue since it's not yet integrated. Add +25-40% once integrated.

---

## 🚀 Action Items

### **TO DO: Integrate Rewarded Interstitial Ad**

1. **Choose a placement** from the 3 options above
2. **Add the `showAd()` call** at your chosen trigger point
3. **Test with test ads** first
4. **Monitor AdMob console** for impressions
5. **Expected revenue increase**: +$0.006-0.012/day per impression

### **Example Integration (Recommended):**

**File**: `lib/ui/screens/quiz/result_screen.dart`

```dart
// Add counter at top of class
int _completedQuizzes = 0;

// In the method that shows results
void _showResultScreen() async {
  _completedQuizzes++;
  
  // Show rewarded interstitial every 2 quizzes
  if (_completedQuizzes % 2 == 0 && 
      context.read<SystemConfigCubit>().isAdsEnable) {
    
    await context.read<RewardedInterstitialAdCubit>().showAd(
      context: context,
      rewardAmount: 15,
      rewardCurrencyLabel: 'coins',
      onAdDismissedCallback: () {
        // Continue to results
        _navigateToResults();
      },
    );
  } else {
    // No ad, go directly to results
    _navigateToResults();
  }
}
```

---

## 📍 Quick Reference: File Locations

### **Ad Cubits (Ad Logic):**
- [app_open_ad_cubit.dart](lib/features/ads/blocs/app_open_ad_cubit.dart) ✅ Integrated
- [banner_ad_cubit.dart](lib/features/ads/blocs/banner_ad_cubit.dart) ✅ Integrated
- [interstitial_ad_cubit.dart](lib/features/ads/blocs/interstitial_ad_cubit.dart) ✅ Integrated
- [rewarded_ad_cubit.dart](lib/features/ads/blocs/rewarded_ad_cubit.dart) ✅ Integrated
- [rewarded_interstitial_ad_cubit.dart](lib/features/ads/blocs/rewarded_interstitial_ad_cubit.dart) ⚠️ Loaded but not shown

### **Ad Widgets:**
- [banner_ad_container.dart](lib/features/ads/widgets/banner_ad_container.dart) - Banner widget
- [ad_consent_dialog.dart](lib/ui/widgets/ad_consent_dialog.dart) - Consent dialog

### **Main Integration:**
- [app.dart](lib/app/app.dart) - BLoC providers registration
- [home_screen.dart](lib/ui/screens/home/home_screen.dart) - Ad initialization

---

## 🎯 User Journey Map

```
App Launch
    ↓
[App Open Ad] (4+ hours since last)
    ↓
Home Screen
    ├── [Banner Ad] (bottom)
    └── Daily Ads Button → [Rewarded Ad]
    ↓
Category Screen
    ├── [Banner Ad] (bottom)
    └── [Interstitial Ad] (on entry)
    ↓
Subcategory Screen
    └── [Banner Ad] (bottom)
    ↓
Quiz Screen
    ├── Lifeline button → [Rewarded Ad]
    └── Complete Quiz
        ↓
    [Interstitial Ad]
        ↓
    Results Screen
        ↓
    [⚠️ Rewarded Interstitial Ad - NOT YET ADDED]
```

---

## 💡 Best Practices

1. **Don't Over-Monetize**: Current frequency is good, don't add more interstitials
2. **Respect User Choice**: Rewarded ads work because users opt-in
3. **Monitor Fill Rates**: Check AdMob console for ad availability
4. **Test First**: Always test with test ad IDs before production
5. **User Experience First**: Ads at natural breaks = better retention

---

## 📞 Support

Need help integrating Rewarded Interstitial ads? Check:
- [APP_OPEN_REWARDED_INTERSTITIAL_GUIDE.md](APP_OPEN_REWARDED_INTERSTITIAL_GUIDE.md)
- [BACKEND_SQL_AND_ADMIN_SETUP.md](BACKEND_SQL_AND_ADMIN_SETUP.md)
- [QUICK_START_BACKEND.md](QUICK_START_BACKEND.md)
