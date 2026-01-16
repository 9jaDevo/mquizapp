# AdMob Compliance Testing Checklist

This document outlines the testing steps for AdMob compliance improvements implemented in Steps 1-5.

## Step 1: Ad Stacking Violations (Frequency Capping)
**Status**: ✅ IMPLEMENTED

### Testing
- [ ] Open Statistics Screen - No interstitial should appear
- [ ] Open Badges Screen - No interstitial should appear
- [ ] Open Notifications Screen - No interstitial should appear
- [ ] Open Quiz → Complete → Result Screen - Interstitial may appear (1st)
- [ ] Immediately go to another Quiz → Complete → Result - Interstitial should be BLOCKED (< 120 seconds)
- [ ] Wait 2 minutes, then trigger ad - Interstitial should appear (allowed)
- [ ] Complete 3 quizzes in a day - After 3rd interstitial, 4th should be blocked (daily limit reached)
- [ ] Check device logs: `adb logcat | grep "AdFrequency"`
  - Should see: "Ad blocked: Only XXs since last ad (need 120s)"
  - Should see: "Ad blocked: Daily limit reached (3/3)"
  - Should see: "Ad recorded: X/3 for today"

---

## Step 2: Rewarded Ads - Consent Dialog & Skip Option
**Status**: ✅ IMPLEMENTED

### Testing - Daily Reward Ad
- [ ] Open Home Screen
- [ ] Tap "Watch Ad" button in daily reward section
- [ ] **AdConsentDialog appears** with:
  - ✅ Reward amount displayed (+X coins)
  - ✅ "Watch Ad" button (prominent)
  - ✅ "Skip" button (always visible)
  - ✅ Clear disclaimer text
- [ ] Tap "Skip" button
  - ✅ Dialog closes
  - ✅ No ad plays
  - ✅ User receives 0 coins
  - ✅ No penalty to game
- [ ] Tap "Watch Ad" button
  - ✅ Ad plays
  - ✅ After completion, "+X coins" snackbar appears
  - ✅ Daily ad quota decrements

### Testing - Lifeline (Insufficient Coins)
- [ ] Enter Quiz
- [ ] Use all coins
- [ ] Attempt to use Lifeline without coins
  - ✅ **AdConsentDialog appears** with lifeline reward amount
  - ✅ "Skip" button allows continuing game without lifeline
  - ✅ "Watch Ad" button shows ad with consent
- [ ] Tap "Skip" - Game continues normally, lifeline unavailable
- [ ] Watch ad again - Receive coins, can now use lifeline

### Testing - Battle Screen (Random Battle)
- [ ] Open Random Battle Screen
- [ ] Insufficient coins for entry
- [ ] Tap "Fight" button
  - ✅ **AdConsentDialog appears** with entry fee reward
  - ✅ Skip/Watch options work as expected

---

## Step 3: Consent Tracking & Logging
**Status**: ✅ IMPLEMENTED

### Testing - User Consent Recording
- [ ] Watch multiple rewarded ads
- [ ] Skip multiple rewarded ads
- [ ] Check device logs: `adb logcat | grep "AdConsent"`
  - Should see: "Ad consent recorded for rewarded_standard (total: X)"
  - Should see: "Ad rejection recorded for rewarded_standard (total: Y)"
- [ ] Verify tracking persists across app restarts
  - Close app
  - Reopen app
  - Watch/Skip ad again
  - Logs should show incremented totals (not reset)

### Testing - Valid Flow Logging
- [ ] Complete a full rewarded ad flow (watch ad → get reward)
- [ ] Device logs should show:
  - ✅ "Ad consent recorded"
  - ✅ "Ad shown" (from AdMob SDK)
  - ✅ "Ad dismissed" (from AdMob SDK)
  - ✅ Coins updated to user profile

---

## Step 4: Lifeline Ads Made Optional
**Status**: ✅ IMPLEMENTED

### Testing - Game Progression Not Blocked
- [ ] Enter Quiz/Battle with insufficient coins
- [ ] View Lifeline Ads
- [ ] **Skip option should:**
  - ✅ Not block game progression
  - ✅ Not force ad viewing
  - ✅ Allow user to continue without lifeline
  - ✅ Not deduct any penalty

### Testing - Multiple Lifeline Attempts
- [ ] Insufficient coins
- [ ] Skip first lifeline ad
- [ ] Attempt second lifeline
  - ✅ Dialog appears again
  - ✅ Can skip again OR watch this time
  - ✅ No duplicate ads if skipped multiple times

### Testing - Ad Dismissal Handling
- [ ] Skip ad mid-dialog (by tapping outside) - Should not work (modal dialog)
- [ ] Skip ad via "Skip" button - Works correctly
- [ ] Complete ad - Coins added, lifeline available

---

## Step 5: Integrated Ad Flow (No Duplicate Dialogs)
**Status**: ✅ IMPLEMENTED

### Testing - Old showWatchAdDialog Removed
Files updated to use integrated consent in showAd():
- ✅ quiz_screen.dart - Removed showWatchAdDialog
- ✅ random_battle_screen.dart - Removed showWatchAdDialog
- ✅ guess_the_word_question_container.dart - Removed showWatchAdDialog

### Testing - Single Dialog Flow
- [ ] Trigger lifeline ad (insufficient coins)
- [ ] Only **ONE** dialog should appear (AdConsentDialog)
- [ ] No double dialogs or nested dialogs
- [ ] Dialog behavior consistent across all screens

### Testing - Timer Handling
- [ ] Quiz with timer running
- [ ] Trigger lifeline ad
  - ✅ Timer stops when dialog appears
  - ✅ Timer resumes when dialog closes (watch or skip)
  - ✅ Timer state preserved correctly

---

## Compliance Verification

### AdMob Policy Checklist
- [ ] **Ad Frequency**: Max 1 per 120 seconds ✅
- [ ] **Daily Limit**: Max 3 per day ✅
- [ ] **Clear Disclosure**: Reward amount shown before ad ✅
- [ ] **Skip Option**: Always available, no penalty ✅
- [ ] **User Autonomy**: Game not blocked by ads ✅
- [ ] **Consent Tracking**: Logged for audit ✅
- [ ] **No Ad Stacking**: Multiple formats don't overlap ✅

### Performance Metrics
- [ ] No crashes when skipping ads
- [ ] No memory leaks with repeated ad cycles
- [ ] Timer accuracy not affected by dialogs
- [ ] State consistency across app restarts

---

## Device Test Commands

```bash
# View AdFrequency logs
adb logcat | grep "AdFrequency"

# View AdConsent logs
adb logcat | grep "AdConsent"

# View RewardedAd logs
adb logcat | grep "RewardedAd"

# View all ads logs
adb logcat | grep -E "AdFrequency|AdConsent|RewardedAd|AdMob"

# Clear logs before test
adb logcat -c
```

---

## Regression Testing

### Critical Flows to Verify
1. **Quiz Flow**: Start → Answer Questions → Result (no interstitials unless allowed)
2. **Lifeline Flow**: Use lifeline with/without coins
3. **Reward Ad Flow**: Skip and watch ads independently
4. **Daily Reward**: Increment/reset counter correctly
5. **Premium Category**: No ads should show
6. **Ads Disabled**: No dialogs when ads are off

---

## Notes
- All testing should be done on device (not emulator for accurate ad behavior)
- Test on both Android and iOS if available
- Document any crashes or unexpected behavior
- Monitor AdMob console for policy violations
