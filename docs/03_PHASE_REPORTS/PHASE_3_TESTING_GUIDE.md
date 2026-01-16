# Phase 3: Complete Testing & Verification Guide

## Overview
This guide provides step-by-step testing procedures for all 9 monetization features integrated in Phase 3.

## Pre-Testing Checklist

Before running tests, ensure:
- [ ] Backend API endpoints are available (Phase 1 & 2 complete)
- [ ] Database migrations executed (5 tables created)
- [ ] Admin settings configured in `tbl_settings`
- [ ] Flutter app built successfully
- [ ] Test device(s) registered (Android and/or iOS)
- [ ] JWT token working properly

## Test Devices Setup

### For Testing
- **Android Test Device:** Physical device or emulator with Play Services
- **iOS Test Device:** Physical device or simulator

### Required Test Accounts
- **Account 1:** Fresh user (for initial registration tests)
- **Account 2:** Established user with 20+ active days (for payout eligibility tests)
- **Account 3:** Suspicious activity pattern (for fraud detection tests)

---

## Feature 1: Device Registration

### Test Case 1.1: Initial Device Registration

**Objective:** Verify device is registered after first login

**Steps:**
1. Install app fresh on test device
2. Complete signup
3. Login to app
4. Check device registered in admin panel

**Expected Result:**
- No errors in app logs
- Device appears in `/admin_backend/Device` screen
- Status shows as "allowed"
- Device ID matches test device

**Admin Verification:**
```
Go to: Admin Panel > Device Management
Expected:
- Device ID: matches test device
- Device Type: android or ios
- Status: allowed
- Created Date: today
```

### Test Case 1.2: Multi-Account Detection

**Objective:** Verify multi-accounting detection

**Steps:**
1. Login to app on Test Device 1 with Account A
2. Login on Test Device 2 with same Account A
3. Check conflict count

**Expected Result:**
- First login: conflict_count = 0 (success)
- Second login: conflict_count = 1 (detected)
- Both devices show same user_id

**Admin Verification:**
```
Go to: Admin Panel > Device Management
Filter by user: Account A
Expected:
- 2 devices listed for same user
- Both marked as active
- Conflict detection triggered
```

### Test Case 1.3: Device Suspension

**Objective:** Verify suspicious devices can be suspended

**Steps:**
1. Register device
2. Go to Admin > Device Management > Suspicious Devices
3. Click "Suspend" button
4. Try login on suspended device

**Expected Result:**
- Suspension reason captured
- Next login attempt shows error
- App displays "Device suspended" message

---

## Feature 2: Daily Streak

### Test Case 2.1: Streak Counter Increment

**Objective:** Verify streak increments on daily login

**Steps:**
1. Login and open app (Day 1)
2. Close app
3. Next day, reopen app
4. Check streak count

**Expected Result:**
- Day 1: streak_count = 1, coins_earned = 10 (default)
- Day 2: streak_count = 2, coins_earned = 10
- Streak widget shows updated count

**Admin Verification:**
```
Go to: Admin Panel > Daily Streak Settings > Statistics
Expected:
- total_active_streaks: 1
- avg_streak: 2
- User listed with 2-day streak
```

### Test Case 2.2: Streak Reset After Miss

**Objective:** Verify streak resets when user misses a day

**Steps:**
1. Login daily for 5 days (streak = 5)
2. Don't login on Day 6
3. Login on Day 7

**Expected Result:**
- Day 7 login: streak_count = 1 (reset)
- max_streak retained at 5
- Coins still awarded for new streak

**Admin Verification:**
```
Go to: Admin Panel > Daily Streak Settings
Expected:
- max_streak: 5 (unchanged)
- Current streak: 1 (reset)
```

### Test Case 2.3: Bonus Unlock at Threshold

**Objective:** Verify bonus coins awarded at threshold

**Steps:**
1. Set daily_streak_bonus_threshold = 3 in admin
2. Login 3 consecutive days
3. Check bonus on Day 3

**Expected Result:**
- Day 3 login: bonus_unlocked = true
- Bonus coins credited to user

**Admin Verification:**
```
Go to: Admin Panel > Daily Streak Settings
Verify settings:
- daily_streak_bonus_threshold: 3
- daily_streak_bonus_coin: 50
User bonus should show in coin history
```

---

## Feature 3: Fraud Detection

### Test Case 3.1: Normal Activity (Non-Suspicious)

**Objective:** Verify normal quiz activity doesn't trigger fraud

**Steps:**
1. Complete quiz normally (60% accuracy, reasonable time)
2. Check fraud detection response
3. Verify no warnings

**Expected Result:**
- is_suspicious = false
- detections array is empty
- No fraudulent flags

**Admin Verification:**
```
Go to: Admin Panel > Fraud Detection Dashboard
Statistics should show:
- total_detections: 0 for normal user
- No entries in pending review
```

### Test Case 3.2: Suspicious Pattern Detection

**Objective:** Verify high accuracy triggers fraud detection

**Steps:**
1. Set fraud_quiz_accuracy_threshold = 95% in admin
2. Complete quiz with 100% accuracy (very fast)
3. Check fraud response

**Expected Result:**
- is_suspicious = true
- detections includes: type=high_accuracy, severity=warning

**Admin Verification:**
```
Go to: Admin Panel > Fraud Detection Dashboard
Expected:
- total_detections: 1
- Detection Type Doughnut Chart updated
- Pending Review: 1 entry
Click detail to see:
- Detection type: high_accuracy
- Severity: warning
- User activity history
```

### Test Case 3.3: Resolution Actions

**Objective:** Verify admin can resolve fraud detections

**Steps:**
1. Trigger fraud detection
2. Go to Admin > Fraud Detection > Detail
3. Click "Suspend" button
4. Add notes "Verified: automated quiz tool"
5. Submit resolution

**Expected Result:**
- Detection marked as resolved
- Status changed from pending to resolved
- Suspension reason logged

---

## Feature 4: Payout Eligibility

### Test Case 4.1: Ineligible User (Fresh Account)

**Objective:** Verify new users can't withdraw immediately

**Steps:**
1. Fresh account (0 active days)
2. Open wallet screen
3. Try to initiate withdrawal

**Expected Result:**
- eligible = false
- eligibility widget shows: "Need 20 more days"
- Withdraw button disabled

**Admin Verification:**
```
Go to: Admin Panel > Payout Eligibility Settings
Settings:
- min_active_days_for_payout: 20
- activity_tracking_window_days: 30
```

### Test Case 4.2: Eligible User (20+ Active Days)

**Objective:** Verify established users can withdraw

**Steps:**
1. Use Account 2 (20+ active days)
2. Open wallet screen
3. Check eligibility status

**Expected Result:**
- eligible = true
- Message: "You are eligible for payout"
- Withdraw button enabled

**Admin Verification:**
```
Go to: Admin Panel > check_payout_eligibility endpoint logs
Expected:
- active_days: 20+
- eligible: true
```

### Test Case 4.3: Eligibility Progress Display

**Objective:** Verify progress bar shows days remaining

**Steps:**
1. Account with 15 active days
2. Open wallet
3. Check eligibility widget

**Expected Result:**
- Progress bar at 75% (15/20)
- Message: "Need 5 more days"
- Days displayed: 15/20

---

## Feature 5: Sponsor Banner

### Test Case 5.1: Banner Display on Home Screen

**Objective:** Verify sponsor banner displays correctly

**Steps:**
1. Go to Admin > Sponsor Banners > Add Banner
2. Create test banner with:
   - sponsor_name: "Test Sponsor"
   - title: "Test Offer"
   - image: upload test image
   - start_date: today
   - end_date: 30 days from now
   - impression_limit: 1000
3. Set banner as active
4. Open home screen on app

**Expected Result:**
- Banner appears on home screen
- Image loads correctly
- Sponsor name visible
- "TAP TO VIEW" indicator visible

**Admin Verification:**
```
Go to: Admin Panel > Sponsor Banners
Expected:
- Banner listed with status: active
- Start date: today
- Impressions: 0 (before tapping)
```

### Test Case 5.2: Banner Click Tracking

**Objective:** Verify clicks are logged

**Steps:**
1. See banner on home screen
2. Tap/Click on banner (don't navigate)
3. Go back to app
4. Check admin panel

**Expected Result:**
- Click logged in admin
- Impression counter increments

**Admin Verification:**
```
Go to: Admin Panel > Sponsor Banners > Detail
Expected:
- total_impressions: 1
- total_clicks: 1
- CTR%: 100% (on detail view)
```

### Test Case 5.3: Impression Limit

**Objective:** Verify banner stops showing after limit

**Steps:**
1. Set impression_limit = 5 for test banner
2. View app home screen 6 times
3. Check if banner still appears

**Expected Result:**
- Banner shows 5 times
- On 6th view, banner not displayed
- No further impressions logged

**Admin Verification:**
```
Go to: Admin Panel > Sponsor Banners > Detail
Expected:
- total_impressions: 5 (max)
- Status: exhausted or inactive
```

---

## Feature 6: Boost Earnings

### Test Case 6.1: Boost Offer Popup

**Objective:** Verify boost offer shown after quiz

**Steps:**
1. Complete quiz successfully
2. Earn 50 coins
3. Check for boost popup

**Expected Result:**
- Popup appears immediately
- Shows: "Double Your Coins!"
- original_coins = 50
- boosted_coins = 100 (with default 2x multiplier)

**Admin Verification:**
```
Go to: Admin Panel > Ad Optimization > Settings
Verify:
- boost_earnings_coin_multiplier: 2.0
```

### Test Case 6.2: Boost Claim

**Objective:** Verify coins doubled when boost claimed

**Steps:**
1. See boost popup (50 → 100 coins)
2. Note current user coins balance
3. Click "Claim Boost"
4. Check new balance

**Expected Result:**
- User coins increased by 100
- Popup closes
- Tracker logged with "quiz_boost" type

**Admin Verification:**
```
Go to: Wallet > User Coin History
Filter by user, search for "quiz_boost" type:
Expected:
- Entry showing +100 coins
- Type: quiz_boost
- Date: today
```

### Test Case 6.3: Boost Skip

**Objective:** Verify user can skip boost offer

**Steps:**
1. See boost popup
2. Note current coins (50 coins base)
3. Click "Skip"
4. Check coins not added

**Expected Result:**
- Only base 50 coins awarded
- Popup closed
- No boost applied

---

## Feature 7: Watch Unlock Premium

### Test Case 7.1: Config Fetch

**Objective:** Verify watch unlock configuration loads

**Steps:**
1. Open premium content screen
2. Check if "Watch X ads to unlock" appears

**Expected Result:**
- Config loaded
- Shows required ad count
- Button enabled (if feature enabled in admin)

**Admin Verification:**
```
Go to: Admin Panel > Ad Settings
Verify:
- watch_unlock_enable: true
- watch_unlock_ad_count: 3
```

### Test Case 7.2: Ad Watch Tracking

**Objective:** Verify ads watched are counted

**Steps:**
1. Open premium content
2. Click "Watch ad" button
3. Watch rewarded ad to completion
4. Verify unlock triggered

**Expected Result:**
- Ad plays to completion
- User gets reward (check logs)
- Ad count decrements
- After required ads, content unlocks

---

## Feature 8: Error Handling & Recovery

### Test Case 8.1: Network Timeout

**Objective:** Verify graceful error handling

**Steps:**
1. Disconnect internet
2. Try to check daily streak
3. Observe error handling
4. Reconnect and retry

**Expected Result:**
- Error shown: "No internet connection"
- Retry button available
- Works after reconnect

### Test Case 8.2: Invalid Token

**Objective:** Verify token refresh works

**Steps:**
1. Clear JWT token (force refresh)
2. Make API call
3. Observe token auto-refresh
4. Call completes successfully

**Expected Result:**
- No login required
- Token auto-refreshed
- Call succeeds

### Test Case 8.3: API Error (500)

**Objective:** Verify server error handling

**Steps:**
1. Trigger API error (using test endpoint)
2. Check app response
3. Verify user-friendly message

**Expected Result:**
- Error message displayed
- App doesn't crash
- User can retry

---

## Feature 9: State Persistence

### Test Case 9.1: Streak Persists Across Sessions

**Objective:** Verify streak data saved correctly

**Steps:**
1. Login, trigger streak check
2. See streak_count = 3
3. Force close app
4. Reopen app

**Expected Result:**
- Streak still shows 3
- Not reset to 0
- Data persisted

### Test Case 9.2: Banner State

**Objective:** Verify banner impression count persists

**Steps:**
1. View banner (impression = 1)
2. Close app completely
3. Reopen app

**Expected Result:**
- Impression count still 1 (not reset to 0)
- Data persisted in database

---

## Load Testing

### Scenario: Concurrent Users

**Setup:**
1. Create 10 test accounts
2. All login simultaneously
3. All trigger device registration
4. All check daily streak
5. Monitor backend performance

**Metrics to Monitor:**
- API response time (target: < 200ms)
- Database connections
- Error rate (target: 0%)
- Memory usage

**Pass Criteria:**
- All 10 users successfully register
- No timeouts
- Response times consistent

---

## Performance Testing

### Scenario: Spam API Calls

**Setup:**
1. Single user makes 50 requests per second
2. Monitor rate limiting

**Expected:**
- Rate limiting kicks in
- User gets 429 Too Many Requests
- Server not overloaded

---

## Admin Panel Verification Checklist

### Verification Steps

**1. Daily Streak Settings Page:**
- [ ] Settings form loads
- [ ] Can modify coin values
- [ ] Statistics display correctly
- [ ] Help text explains logic

**2. Device Management Page:**
- [ ] Device list shows all registered devices
- [ ] Can search by user
- [ ] Can suspend device
- [ ] Suspension reason captured

**3. Fraud Detection Dashboard:**
- [ ] Statistics cards show correct counts
- [ ] Detection type chart displays
- [ ] Severity chart displays
- [ ] Paginated table works
- [ ] Detail popup opens

**4. Sponsor Banners Page:**
- [ ] Can add new banner
- [ ] Can edit banner
- [ ] Can delete banner
- [ ] Image uploads work
- [ ] Date range validation works

**5. Payout Eligibility Page:**
- [ ] Settings form loads
- [ ] Documentation visible
- [ ] Example scenarios shown
- [ ] API response example displayed

---

## Test Results Template

```markdown
## Test Results - Phase 3

| Feature | Test Case | Status | Notes | Date |
|---------|-----------|--------|-------|------|
| Device Registration | Initial Registration | ✅ PASS | Device registered correctly | 2026-01-16 |
| Device Registration | Multi-Account Detection | ⚠️ REVIEW | Conflict count showing | 2026-01-16 |
| Daily Streak | Increment | ✅ PASS | Works as expected | 2026-01-16 |
| Fraud Detection | Normal Activity | ✅ PASS | No false positives | 2026-01-16 |
| ... | ... | ... | ... | ... |

**Summary:**
- Total Tests: XX
- Passed: XX
- Failed: XX
- Blocked: XX
- Pass Rate: XX%
```

---

## Troubleshooting Guide

### Issue: "Device already registered" Error

**Cause:** App trying to register same device twice

**Solution:**
1. Check if device already in database
2. Verify timestamp, don't re-register same device
3. Update device info instead of creating new

### Issue: Streak Not Incrementing

**Cause:** Daily check not triggering on app open

**Solution:**
1. Check if checkDailyStreak() called on app resume
2. Verify BLoC initialization
3. Check if API endpoint responding

### Issue: Fraud False Positives

**Cause:** Threshold too strict

**Solution:**
1. Go to Admin > Fraud Detection Settings
2. Adjust fraud_quiz_accuracy_threshold (increase value)
3. Retest with normal quiz completion

### Issue: Banner Not Showing

**Cause:** No active banner in date range

**Solution:**
1. Check Admin > Sponsor Banners
2. Verify banner start_date <= today
3. Verify banner end_date >= today
4. Verify banner status = active

### Issue: Payout Check Takes Too Long

**Cause:** Query performance issue on large tbl_daily_streak

**Solution:**
1. Add INDEX on user_id and created_date
2. Limit query to 30-day window only
3. Cache result for 1 hour

---

## Sign-Off

**Phase 3 Testing Completed:**
- [ ] All 9 features tested
- [ ] All error scenarios verified
- [ ] Admin panel validated
- [ ] Load testing passed
- [ ] Performance acceptable
- [ ] Ready for production deployment

**Tested By:** _________________
**Date:** _________________
**Approved By:** _________________
