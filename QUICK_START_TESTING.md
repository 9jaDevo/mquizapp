# 🚀 Quick Start - Phase 3 Monetization System

**Status:** ✅ Ready to Test  
**Time to Test:** 30 minutes  
**Prerequisites:** Backend running, App installed on device/emulator

---

## 1. Start Backend Server (5 min)

```bash
# Make sure XAMPP is running
# Apache: ✅ Started
# MySQL: ✅ Started

# Verify database
- Open phpMyAdmin: http://localhost/phpmyadmin
- Database: flutterquiz (or your database name)
- Tables should include:
  ✅ tbl_daily_streak
  ✅ tbl_device_mapping
  ✅ tbl_fraud_detection
  ✅ tbl_sponsor_banners
  ✅ tbl_banner_impressions
  ✅ tbl_payout_eligibility_settings
  ✅ tbl_watch_unlock_settings
```

---

## 2. Configure Admin Settings (10 min)

### A. Daily Streak Settings
1. Open: `http://localhost/mquizapp/admin_backend/daily_streak_settings.php`
2. Configure:
   - Coins per day: 10
   - Bonus threshold: 7 days
   - Bonus coins: 50
   - Max streak: 30 days
3. Click "Save Settings"

### B. Add Sponsor Banner
1. Open: `http://localhost/mquizapp/admin_backend/sponsor_banners.php`
2. Click "Add New Banner"
3. Fill:
   - Sponsor Name: "Test Sponsor"
   - Title: "Amazing App!"
   - Image URL: (use any valid image URL)
   - Redirect URL: "https://example.com"
   - Priority: 1
   - Status: Active
4. Click "Add Banner"

### C. Payout Eligibility
1. Open: `http://localhost/mquizapp/admin_backend/payout_eligibility_settings.php`
2. Set:
   - Required active days: 7
   - Minimum coins: 1000
3. Click "Save"

### D. Watch Unlock
1. Open: `http://localhost/mquizapp/admin_backend/watch_unlock_settings.php`
2. Configure:
   - Enable: Yes
   - Ad count required: 3
3. Click "Save"

---

## 3. Build & Run Flutter App (5 min)

```bash
cd c:\xampp\htdocs\mquizapp

# Install dependencies (if not done)
flutter pub get

# Run on connected device/emulator
flutter run

# Or build APK for testing
flutter build apk --debug
```

**Wait for app to launch...**

---

## 4. Test Each Feature (10 min)

### ✅ Test 1: Device Registration (30 sec)
**Steps:**
1. Open app
2. Login with test account

**Expected:**
- Login successful
- Device registered automatically (check console logs)

**Verify in Admin:**
- Open: `http://localhost/mquizapp/admin_backend/device_management.php`
- Your device should appear in list

---

### ✅ Test 2: Daily Streak (1 min)
**Steps:**
1. After login, home screen loads
2. Wait 500ms

**Expected:**
- Daily streak widget appears on home screen
- Shows: "🔥 1 Day Streak! Earned: 10 coins"

**Verify in Database:**
```sql
SELECT * FROM tbl_daily_streak WHERE user_id = YOUR_USER_ID;
-- Should show: current_streak = 1, coins_earned_today = 10
```

---

### ✅ Test 3: Sponsor Banner (1 min)
**Steps:**
1. Scroll down on home screen
2. Look for sponsor banner

**Expected:**
- Banner displays with sponsor name and title
- Shows image from URL
- Has "👆 Tap to visit" indicator

**Action:**
1. Tap banner
2. Browser should open with redirect URL

**Verify in Database:**
```sql
SELECT * FROM tbl_banner_impressions ORDER BY timestamp DESC LIMIT 5;
-- Should show impression and click records
```

---

### ✅ Test 4: Fraud Detection (1 min)
**Steps:**
1. Play any quiz
2. Complete quiz (any score)

**Expected:**
- Quiz completes normally
- No visible change (fraud runs in background)

**Verify in Admin:**
- Open: `http://localhost/mquizapp/admin_backend/fraud_detection_dashboard.php`
- Should show quiz completion record
- Risk status: Clean (if played normally)

---

### ✅ Test 5: Boost Earnings (2 min)
**Steps:**
1. Complete a quiz with at least 1 correct answer
2. Wait for result screen to appear

**Expected:**
- Boost earnings dialog pops up
- Shows: "Original: X coins → Boosted: 2X coins"
- Two buttons: "Claim" and "Skip"

**Action:**
1. Click "Claim"
2. Watch ad (if ad loaded)
3. Dialog closes
4. Boosted coins credited

**Alternative:**
1. Click "Skip"
2. Original coins credited

---

### ✅ Test 6: Payout Eligibility (1 min)
**Steps:**
1. Open wallet screen (from bottom nav)
2. Go to "Request" tab

**Expected:**
- Payout eligibility widget shows at top
- Displays: "Play X more days to unlock payout"
- Progress bar shows: "1/7 days active"

---

### ✅ Test 7: Watch Unlock (3 min)
**Steps:**
1. Go to quiz categories
2. Find a premium (locked) category
3. Click premium category

**Expected:**
- Unlock dialog opens
- Message: "Watch 3 ads to unlock OR use 500 coins"
- Button: "Watch Ad (0/3)"

**Action:**
1. Click "Watch Ad (0/3)"
2. Watch ad (if loaded)
3. Button changes to "Watch Ad (1/3)"
4. Repeat 2 more times
5. After 3 ads, button becomes "Unlock Now"
6. Click "Unlock Now"
7. Category unlocks without deducting coins!

---

## 5. Verify All Data (5 min)

### Check Database Tables

**Daily Streak:**
```sql
SELECT * FROM tbl_daily_streak;
-- Should have 1 row with your user_id
```

**Device Mapping:**
```sql
SELECT * FROM tbl_device_mapping;
-- Should have 1 row with your device info
```

**Fraud Detection:**
```sql
SELECT * FROM tbl_fraud_detection ORDER BY timestamp DESC LIMIT 10;
-- Should show quiz completion records
```

**Banner Impressions:**
```sql
SELECT * FROM tbl_banner_impressions ORDER BY timestamp DESC LIMIT 10;
-- Should show impression and click records
```

---

## 6. Admin Dashboard Tour (5 min)

### View All Admin Pages:

1. **Daily Streak Settings**
   - URL: `http://localhost/mquizapp/admin_backend/daily_streak_settings.php`
   - Check: Settings are saved

2. **Device Management**
   - URL: `http://localhost/mquizapp/admin_backend/device_management.php`
   - Check: Your device appears
   - Try: Click "Suspend" button (should disable device)

3. **Fraud Detection Dashboard**
   - URL: `http://localhost/mquizapp/admin_backend/fraud_detection_dashboard.php`
   - Check: Quiz completion records appear
   - Check: Risk scores calculated

4. **Sponsor Banners**
   - URL: `http://localhost/mquizapp/admin_backend/sponsor_banners.php`
   - Check: Banner you added appears
   - Try: Edit banner details

5. **Banner Analytics**
   - URL: `http://localhost/mquizapp/admin_backend/banner_analytics.php`
   - Check: Shows impressions and clicks
   - Check: CTR calculated

6. **Payout Eligibility Settings**
   - URL: `http://localhost/mquizapp/admin_backend/payout_eligibility_settings.php`
   - Check: Settings are saved

7. **Watch Unlock Settings**
   - URL: `http://localhost/mquizapp/admin_backend/watch_unlock_settings.php`
   - Check: Settings are saved

---

## Common Test Scenarios

### Scenario 1: Multi-Day Streak
**Objective:** Test streak continuity

**Steps:**
1. Login today (Day 1) → Streak = 1
2. Change system date to tomorrow
3. Login again (Day 2) → Streak = 2
4. Change date again
5. Login (Day 3) → Streak = 3

**Expected:**
- Streak increments each day
- Coins awarded daily
- Max streak updates

---

### Scenario 2: Device Conflict
**Objective:** Test multi-device detection

**Steps:**
1. Login on Device A
2. Login on Device B (different device ID)
3. Check admin panel

**Expected:**
- Both devices registered
- Conflict count = 1
- Admin can see both devices for same user

---

### Scenario 3: Fraud Detection
**Objective:** Trigger fraud alert

**Steps:**
1. Complete quiz very fast (e.g., 3 seconds)
2. Score 100% accuracy
3. Check fraud dashboard

**Expected:**
- Detection: "Too fast, too accurate"
- Risk status: High
- Admin alert generated

---

### Scenario 4: 7-Day Streak Bonus
**Objective:** Unlock bonus reward

**Steps:**
1. Login for 7 consecutive days
2. On day 7, check home screen

**Expected:**
- Streak widget shows: "🔥 7 Day Streak!"
- Bonus unlocked message
- Extra 50 coins awarded

---

## Troubleshooting Quick Fixes

### Issue 1: "Device registration failed"
**Fix:**
```bash
# Check if device_info_plus is installed
flutter pub get

# Check backend API
curl -X POST http://localhost/mquizapp/admin_backend/api.php/register_device \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

---

### Issue 2: "Daily streak not updating"
**Fix:**
1. Check database: `SELECT * FROM tbl_daily_streak;`
2. Verify server timezone matches database
3. Check API logs for errors

---

### Issue 3: "Banner not loading"
**Fix:**
1. Verify banner is active in admin panel
2. Check image URL is accessible
3. Check API response: `GET /get_sponsor_banner`

---

### Issue 4: "Boost popup not showing"
**Fix:**
1. Ensure quiz has correct answers (baseCoins > 0)
2. Check console logs for errors
3. Verify boost settings in admin panel

---

## Success Checklist

After testing, you should have:

- ✅ Device registered in database
- ✅ Daily streak record created
- ✅ Sponsor banner displayed and clicked
- ✅ Fraud detection logged quiz completion
- ✅ Boost earnings dialog appeared
- ✅ Payout eligibility widget displayed
- ✅ Watch unlock dialog showed ad option
- ✅ All 7 admin pages accessible
- ✅ Database tables populated with test data
- ✅ No compilation errors in app
- ✅ No API errors in backend logs

---

## Next Steps After Testing

1. **Customize Settings:**
   - Adjust coin rewards
   - Set your bonus thresholds
   - Configure fraud detection sensitivity

2. **Add Real Sponsor Banners:**
   - Get sponsor agreements
   - Upload professional banners
   - Set click tracking

3. **Production Deployment:**
   - Update API endpoints to production
   - Configure SSL certificates
   - Set up database backups

4. **Monitor Performance:**
   - Track daily active users
   - Analyze fraud patterns
   - Optimize banner CTR

5. **Gather User Feedback:**
   - Survey users about features
   - Adjust based on feedback
   - Iterate and improve

---

## Testing Completed? 🎉

If all tests pass, you're ready to:
- Deploy to production
- Enable for all users
- Start monetizing!

---

## Support

Need help? Check:
- `PHASE_3_TROUBLESHOOTING_GUIDE.md` - Common issues
- `MONETIZATION_SYSTEM_OVERVIEW.md` - System architecture
- `PHASE_3_TESTING_GUIDE.md` - Detailed test cases

---

**Happy Testing! 🚀**
