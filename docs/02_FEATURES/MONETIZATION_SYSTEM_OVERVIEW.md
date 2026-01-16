# Monetization System - Complete Overview

**Status:** ✅ Fully Implemented (Phases 1, 2, 3 Complete)

---

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    FLUTTER APP (Frontend)                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────────┐    ┌──────────────────┐              │
│  │ MonetizationCubit│────│ Remote DataSource│              │
│  └──────────────────┘    └──────────────────┘              │
│           │                      │                           │
│           │ States               │ HTTP Calls                │
│           ▼                      ▼                           │
│  ┌──────────────────┐    ┌──────────────────┐              │
│  │  Monetization    │    │   API Endpoints  │              │
│  │     Widgets      │    │  (9 endpoints)   │              │
│  └──────────────────┘    └──────────────────┘              │
│                                  │                           │
└──────────────────────────────────┼───────────────────────────┘
                                   │ JSON over HTTP
                                   │ JWT Authentication
┌──────────────────────────────────┼───────────────────────────┐
│                    BACKEND (CodeIgniter 3)                   │
├──────────────────────────────────┼───────────────────────────┤
│                                   ▼                           │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Api.php Controller                       │   │
│  │  - check_daily_streak_post()                          │   │
│  │  - register_device_post()                             │   │
│  │  - evaluate_user_risk_post()                          │   │
│  │  - check_payout_eligibility_post()                    │   │
│  │  - get_sponsor_banner_post()                          │   │
│  │  - sponsor_banner_click_post()                        │   │
│  │  - offer_boost_earnings_post()                        │   │
│  │  - apply_boost_earnings_post()                        │   │
│  │  - get_watch_unlock_config_post()                     │   │
│  └──────────────────────────────────────────────────────┘   │
│                          │                                    │
│                          ▼                                    │
│  ┌────────────────────────────────────────────────┐         │
│  │              Business Logic Models              │         │
│  │  - Streak_model.php                             │         │
│  │  - Device_model.php                             │         │
│  │  - Fraud_model.php                              │         │
│  │  - Sponsor_model.php                            │         │
│  └────────────────────────────────────────────────┘         │
│                          │                                    │
│                          ▼                                    │
│  ┌────────────────────────────────────────────────┐         │
│  │              MySQL Database                     │         │
│  │  - tbl_daily_streak                             │         │
│  │  - tbl_device_mapping                           │         │
│  │  - tbl_fraud_detection                          │         │
│  │  - tbl_sponsor_banners                          │         │
│  │  - tbl_banner_impressions                       │         │
│  │  - tbl_payout_eligibility_settings              │         │
│  │  - tbl_watch_unlock_settings                    │         │
│  └────────────────────────────────────────────────┘         │
│                                                               │
└───────────────────────────────────────────────────────────────┘

┌───────────────────────────────────────────────────────────────┐
│                   ADMIN PANEL (CodeIgniter Views)             │
├───────────────────────────────────────────────────────────────┤
│  - daily_streak_settings.php                                  │
│  - device_management.php                                      │
│  - fraud_detection_dashboard.php                              │
│  - sponsor_banners.php                                        │
│  - payout_eligibility_settings.php                            │
│  - watch_unlock_settings.php                                  │
│  - banner_analytics.php                                       │
└───────────────────────────────────────────────────────────────┘
```

---

## 9 Core Features

### 1. Daily Streak System ⭐
**Purpose:** Reward users for logging in daily

**Flow:**
1. User opens app → `home_screen.dart` calls `checkDailyStreak()`
2. Backend checks `tbl_daily_streak` for user's last login
3. If new day: increment streak, award coins, check bonus milestones
4. Return: streak_count, coins_earned, bonus_unlocked, max_streak
5. UI displays animated DailyStreakWidget on home screen

**Admin Control:**
- Set coins per day (default: 10)
- Configure bonus thresholds (e.g., 7 days = 50 coins)
- Set max streak limit (default: 30 days)

**Database:** `tbl_daily_streak`
```sql
CREATE TABLE tbl_daily_streak (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  current_streak INT DEFAULT 0,
  max_streak INT DEFAULT 0,
  last_login_date DATE NOT NULL,
  coins_earned_today INT DEFAULT 0,
  bonus_unlocked BOOLEAN DEFAULT 0
);
```

---

### 2. Device Registration 📱
**Purpose:** Track user devices and detect multi-device fraud

**Flow:**
1. User logs in → `home_screen.dart` calls `_registerDevice()`
2. Get device info: deviceId (UUID), deviceType (android/ios), deviceName
3. Backend checks `tbl_device_mapping` for existing device
4. If new device: add record, check for conflicts (same user, different device)
5. Return: status, message, conflict_count

**Admin Control:**
- View all registered devices per user
- Suspend suspicious devices
- Set max devices per user (default: 3)

**Database:** `tbl_device_mapping`
```sql
CREATE TABLE tbl_device_mapping (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  device_id VARCHAR(255) NOT NULL,
  device_type ENUM('android', 'ios') NOT NULL,
  device_name VARCHAR(255) NOT NULL,
  first_registered TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_active TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_suspended BOOLEAN DEFAULT 0
);
```

---

### 3. Sponsor Banner Display 📢
**Purpose:** Show paid advertisements to users

**Flow:**
1. Home screen loads → `_buildSponsorBanner()` calls `getSponsorBanner()`
2. Backend fetches active banner from `tbl_sponsor_banners` (random or priority-based)
3. Record impression in `tbl_banner_impressions`
4. Return: banner_id, sponsor_name, title, image_url, redirect_url
5. User clicks banner → `recordBannerClick()` logs to database → launch URL

**Admin Control:**
- Add/edit/delete sponsor banners
- Set banner priority and status
- View analytics: impressions, clicks, CTR
- Configure banner rotation strategy

**Database:** `tbl_sponsor_banners`, `tbl_banner_impressions`
```sql
CREATE TABLE tbl_sponsor_banners (
  banner_id INT PRIMARY KEY AUTO_INCREMENT,
  sponsor_name VARCHAR(255) NOT NULL,
  title VARCHAR(255) NOT NULL,
  image_url TEXT NOT NULL,
  redirect_url TEXT NOT NULL,
  priority INT DEFAULT 1,
  is_active BOOLEAN DEFAULT 1
);

CREATE TABLE tbl_banner_impressions (
  id INT PRIMARY KEY AUTO_INCREMENT,
  banner_id INT NOT NULL,
  user_id INT NOT NULL,
  action_type ENUM('impression', 'click') NOT NULL,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

### 4. Boost Earnings Popup 🚀
**Purpose:** Offer coin multiplier after quiz completion

**Flow:**
1. User completes quiz → `quiz_screen.dart` calls `offerBoostEarnings(baseCoins)`
2. Backend calculates boosted amount (baseCoins * multiplier)
3. Return: original_coins, boosted_coins, multiplier, coin_difference
4. Show BoostEarningsDialog with "Claim" (watch ad) or "Skip" options
5. User claims → `applyBoostEarnings()` credits boosted coins to user

**Admin Control:**
- Set multiplier (default: 2x)
- Configure ad requirement (yes/no)
- Set maximum boost per day

**UI Example:**
```
┌─────────────────────────────┐
│    🚀 Boost Your Earnings!  │
├─────────────────────────────┤
│  Original:    50 coins      │
│  Boosted:     100 coins 🎉  │
│  Multiplier:  2x            │
├─────────────────────────────┤
│  [Watch Ad & Claim] [Skip]  │
└─────────────────────────────┘
```

---

### 5. Fraud Detection 🔍
**Purpose:** Monitor suspicious activity patterns

**Flow:**
1. User completes quiz → `_evaluateFraudRisk()` calls `evaluateUserRisk()`
2. Send metadata: quiz_score, time_taken, accuracy, quiz_type
3. Backend analyzes patterns (too fast, too accurate, unusual timing)
4. Log suspicious activity to `tbl_fraud_detection`
5. Return: is_suspicious, detections[] (array of flags)
6. If suspicious: show warning or restrict account

**Admin Control:**
- View fraud detection dashboard
- Configure detection thresholds
- Manually flag/unflag users
- Set auto-suspension rules

**Detection Patterns:**
- Quiz completed in < 5 seconds
- 100% accuracy consistently
- Playing at unusual hours (2-4 AM)
- Device conflicts
- Rapid coin accumulation

**Database:** `tbl_fraud_detection`
```sql
CREATE TABLE tbl_fraud_detection (
  id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT NOT NULL,
  action_type VARCHAR(50) NOT NULL,
  metadata TEXT,
  is_suspicious BOOLEAN DEFAULT 0,
  detections TEXT,
  timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

### 6. Payout Eligibility Check 💰
**Purpose:** Ensure users meet requirements before withdrawing

**Flow:**
1. User opens wallet screen → `checkPayoutEligibility()` called in initState
2. Backend counts active days (days with at least one quiz played)
3. Compare active_days vs required_days (from settings)
4. Return: eligible, active_days, required_days, message
5. Display PayoutEligibilityWidget with progress bar

**Admin Control:**
- Set required active days (default: 7 days)
- Configure minimum coins requirement
- Set maximum payout per month

**UI Example:**
```
┌─────────────────────────────────────┐
│  📅 Payout Eligibility              │
├─────────────────────────────────────┤
│  ████████░░ 8/10 days active        │
│                                      │
│  Play 2 more days to unlock payout! │
└─────────────────────────────────────┘
```

---

### 7. Daily Streak UI Widget 🔥
**Purpose:** Visual display of user's login streak

**Flow:**
1. After `checkDailyStreak()` completes → state emits `DailyStreakChecked`
2. `_buildDailyStreakWidget()` displays DailyStreakWidget
3. Animated gradient card with:
   - Fire emoji (🔥) and streak count
   - Coins earned today
   - Bonus status (if unlocked)
   - Max streak record

**Widget Features:**
- Gradient background (blue → purple)
- Animated entrance
- Tap to view streak history
- Shows "NEW RECORD!" when max streak beaten

**UI Example:**
```
┌────────────────────────────────┐
│  🔥 7 Day Streak!              │
│  Earned: 10 coins today        │
│  Bonus: 50 coins unlocked! 🎉  │
│  Best: 15 days                 │
└────────────────────────────────┘
```

---

### 8. Watch Unlock Premium 🎬
**Purpose:** Allow users to unlock premium categories by watching ads

**Flow:**
1. User clicks premium category → unlock dialog opens
2. `getWatchUnlockConfig()` fetches settings (enabled, ad_count_required)
3. Show two options:
   - Pay X coins
   - Watch Y ads to unlock
4. User watches ad → `_adsWatched` counter increments
5. After Y ads watched → unlock category without coins

**Admin Control:**
- Enable/disable watch unlock feature
- Set ad count required (default: 3 ads)
- Configure eligible categories

**UI Flow:**
```
Dialog 1: Watch 3 ads to unlock OR use 500 coins
          [Watch Ad (0/3)] [Cancel]

Dialog 2: Watch 2 ads to unlock OR use 500 coins
          [Watch Ad (1/3)] [Cancel]

Dialog 3: Watch 1 ad to unlock OR use 500 coins
          [Watch Ad (2/3)] [Cancel]

Dialog 4: You watched 3 ads!
          [Unlock Now] [Cancel]
```

---

### 9. Fraud Detection Dashboard 📊
**Purpose:** Admin monitoring of suspicious activities

**Features:**
- Real-time fraud alerts
- User risk scores
- Activity timeline
- Auto-suspension triggers

**Admin View:**
```
┌───────────────────────────────────────────────────┐
│  Fraud Detection Dashboard                        │
├───────────────────────────────────────────────────┤
│  ⚠️  High Risk Users: 5                           │
│  🔍  Active Investigations: 2                     │
│  🚫  Auto-Suspended Today: 1                      │
├───────────────────────────────────────────────────┤
│  Recent Detections:                                │
│  User #123 - Too Fast Quiz (5 sec, 100% accuracy) │
│  User #456 - Device Conflict (3 devices)          │
│  User #789 - Unusual Hours (2:30 AM)              │
└───────────────────────────────────────────────────┘
```

---

## User Journey Examples

### Example 1: New User First Day
1. User signs up and logs in
2. Device registered automatically ✅
3. Home screen shows: "🔥 1 Day Streak! Earned: 10 coins"
4. User plays quiz and scores 8/10
5. Boost popup: "50 coins → 100 coins (2x multiplier)"
6. User watches ad and claims 100 coins
7. Fraud detection: Clean, no flags

### Example 2: 7-Day Streak User
1. User logs in on day 7
2. Daily streak check: Bonus unlocked! (50 coins)
3. Home screen shows: "🔥 7 Day Streak! Bonus: 50 coins! 🎉"
4. User wants to unlock premium category
5. Wallet shows: "Payout eligible! 7/7 days active"
6. User can now withdraw coins

### Example 3: Suspicious Activity
1. User completes quiz in 3 seconds with 100% accuracy
2. Fraud detection flags: "Too fast, too accurate"
3. Admin gets alert in dashboard
4. User's next payout requires manual review

---

## Integration Points

### Home Screen (`home_screen.dart`)
- Device registration on app start
- Daily streak check (500ms delay)
- Daily streak widget display
- Sponsor banner display

### Quiz Screen (`quiz_screen.dart`)
- Fraud detection after quiz
- Boost earnings popup after quiz

### Wallet Screen (`wallet_screen.dart`)
- Payout eligibility check
- Eligibility widget display

### Premium Dialog (`unlock_premium_category_dialog.dart`)
- Watch unlock config fetch
- Ad watching functionality
- Unlock tracking

---

## Admin Panel Pages

1. **daily_streak_settings.php**
   - Configure coins per day
   - Set bonus thresholds
   - Max streak limit

2. **device_management.php**
   - View all user devices
   - Suspend/unsuspend devices
   - Device conflict alerts

3. **fraud_detection_dashboard.php**
   - High-risk users list
   - Detection patterns
   - Auto-suspension rules

4. **sponsor_banners.php**
   - Add/edit/delete banners
   - Upload banner images
   - Set priority and status

5. **payout_eligibility_settings.php**
   - Active days requirement
   - Minimum coins for payout
   - Monthly payout limits

6. **watch_unlock_settings.php**
   - Enable/disable feature
   - Ad count configuration
   - Eligible categories

7. **banner_analytics.php**
   - Impressions vs clicks
   - CTR by banner
   - Revenue tracking

---

## API Authentication

All API calls require JWT token in header:
```
Authorization: Bearer <JWT_TOKEN>
```

Token obtained from user login and stored in app's secure storage.

---

## Error Handling

### Frontend (Flutter)
```dart
try {
  final result = await monetizationCubit.checkDailyStreak();
  // Handle success
} catch (e) {
  // Show error message
  context.showSnack('Failed to check daily streak');
}
```

### Backend (PHP)
```php
if ($this->validateToken()) {
    $userId = $this->userId;
    $result = $this->Streak_model->handle_daily_login($userId);
    echo json_encode($result);
} else {
    $this->response(['error' => 'Unauthorized'], 401);
}
```

---

## Performance Considerations

1. **Database Indexing:**
   - Index on `user_id` in all tables
   - Index on `last_login_date` in tbl_daily_streak
   - Index on `device_id` in tbl_device_mapping

2. **Caching:**
   - Cache sponsor banners for 5 minutes
   - Cache payout eligibility for 1 hour
   - Cache watch unlock config for 10 minutes

3. **Rate Limiting:**
   - Max 10 API calls per minute per user
   - Max 3 device registrations per day
   - Max 5 boost claims per day

---

## Security Measures

1. **JWT Token Validation:** All API calls require valid token
2. **SQL Injection Prevention:** Parameterized queries in all models
3. **XSS Protection:** Sanitize all user inputs
4. **CSRF Protection:** Token validation on state-changing operations
5. **Rate Limiting:** Prevent API abuse
6. **Device Fingerprinting:** Detect device spoofing

---

## Monitoring & Analytics

### Key Metrics to Track:
- Daily active users (DAU)
- Streak completion rate
- Banner CTR (Click-Through Rate)
- Boost claim rate
- Fraud detection accuracy
- Payout request volume
- Watch unlock conversion rate

### Dashboard Widgets:
1. Total coins distributed today
2. Active streaks count
3. Banner impressions/clicks
4. Fraud alerts (last 24h)
5. Pending payout requests
6. Most popular premium categories

---

## Deployment Checklist

### Before Going Live:
- [ ] Test all 9 features end-to-end
- [ ] Verify admin panel access
- [ ] Configure production database
- [ ] Set up SSL certificate
- [ ] Enable error logging
- [ ] Configure backup schedule
- [ ] Test JWT token expiry
- [ ] Verify API rate limits
- [ ] Load test banner serving
- [ ] Test fraud detection rules

### Post-Deployment:
- [ ] Monitor API response times
- [ ] Check error logs daily
- [ ] Review fraud alerts
- [ ] Analyze banner performance
- [ ] Track payout requests
- [ ] Gather user feedback

---

## Future Enhancements

1. **Referral System:** Earn coins by inviting friends
2. **Leaderboard Integration:** Show top streak holders
3. **Push Notifications:** Remind users to maintain streak
4. **Seasonal Events:** Special bonus multipliers
5. **Streak Insurance:** Buy streak protection
6. **Social Sharing:** Share streak milestones
7. **Advanced Analytics:** ML-based fraud detection
8. **A/B Testing:** Test different multipliers

---

## Support & Troubleshooting

### Common Issues:

**1. Daily streak not updating:**
- Check server time vs user local time
- Verify database timestamp format
- Ensure cron job is running

**2. Banner not loading:**
- Check image URL accessibility
- Verify banner status is active
- Check database connection

**3. Boost not applying:**
- Verify ad completion callback
- Check user coin balance
- Ensure transaction is logged

**4. Fraud false positives:**
- Adjust detection thresholds
- Whitelist specific users
- Review detection patterns

For detailed troubleshooting, see: `PHASE_3_TROUBLESHOOTING_GUIDE.md`

---

## Documentation Files

1. `PHASE_3_INTEGRATION_GUIDE.md` - Step-by-step integration
2. `PHASE_3_TESTING_GUIDE.md` - 25+ test cases
3. `PHASE_3_TROUBLESHOOTING_GUIDE.md` - Common issues
4. `PHASE_3_IMPLEMENTATION_COMPLETE.md` - Implementation summary
5. `MONETIZATION_SYSTEM_OVERVIEW.md` - This file

---

**System Status:** 🟢 Fully Operational  
**Last Updated:** Current Session  
**Version:** 1.0.0  
**Total LOC:** ~3,000 lines (Backend + Frontend)

---

**End of Overview**
