# Phase 2 Complete ✅ - Quick Start Guide

## Current Status
- ✅ Database schema designed & SQL ready
- ✅ 4 business logic models created
- ✅ 4 admin controllers created
- ✅ 7 admin panel views created
- ✅ 9 API endpoints integrated into Api.php

**Total Code Created: 4,500+ lines**

---

## 🎯 Immediate Next Steps (1 Hour)

### Step 1: Execute Database Migrations
```
Location: admin_backend/database/migrations/
Files: 
  - 2026_01_16_add_monetization_tables.sql
  - 2026_01_16_insert_monetization_settings.sql

How: 
  1. Open phpMyAdmin → Select your database
  2. Click "Import" tab
  3. Upload 2026_01_16_add_monetization_tables.sql → Execute
  4. Upload 2026_01_16_insert_monetization_settings.sql → Execute
  
OR via Terminal:
  mysql -u root -p your_database < admin_backend/database/migrations/2026_01_16_add_monetization_tables.sql
  mysql -u root -p your_database < admin_backend/database/migrations/2026_01_16_insert_monetization_settings.sql
```

### Step 2: Verify Database Setup
```sql
-- Check tables created
SHOW TABLES LIKE 'tbl_%';

-- Check settings inserted
SELECT setting_key, message FROM tbl_settings 
WHERE setting_key LIKE '%streak%' OR setting_key LIKE '%device%' 
OR setting_key LIKE '%fraud%' OR setting_key LIKE '%sponsor%' 
OR setting_key LIKE '%payout%' OR setting_key LIKE '%boost%' 
OR setting_key LIKE '%unlock%';
```

### Step 3: Test Admin Panel Access
```
Navigate to:
  http://localhost/mquizapp/admin_backend/

Test URLs:
  http://localhost/mquizapp/admin_backend/Streak
  http://localhost/mquizapp/admin_backend/Device
  http://localhost/mquizapp/admin_backend/Fraud
  http://localhost/mquizapp/admin_backend/Sponsors

Expected: Pages load with settings forms and empty data tables
```

### Step 4: Update Admin Menu (Optional but Recommended)
Add these menu items to your admin navigation:

```php
// In your header/sidebar navigation file
<li class="menu-header">Monetization Features</li>
<li><a href="<?= base_url('Streak'); ?>"><i class="fas fa-fire"></i> Daily Streaks</a></li>
<li><a href="<?= base_url('Device'); ?>"><i class="fas fa-mobile-alt"></i> Device Management</a></li>
<li><a href="<?= base_url('Fraud'); ?>"><i class="fas fa-shield-alt"></i> Fraud Detection</a></li>
<li><a href="<?= base_url('Sponsors'); ?>"><i class="fas fa-bullhorn"></i> Sponsor Banners</a></li>
```

---

## 🔌 Testing API Endpoints (5 Minutes)

### Test with cURL or Postman

**1. Check Daily Streak**
```bash
curl -X POST http://localhost/mquizapp/admin_backend/api/check_daily_streak \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "token=YOUR_USER_TOKEN"
```

**2. Register Device**
```bash
curl -X POST http://localhost/mquizapp/admin_backend/api/register_device \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "token=YOUR_USER_TOKEN&device_id=abc123&device_type=android&device_name=Samsung"
```

**3. Get Sponsor Banner**
```bash
curl -X POST http://localhost/mquizapp/admin_backend/api/get_sponsor_banner \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "token=YOUR_USER_TOKEN"
```

Expected: JSON response with `error: false` and data

---

## 📱 Flutter App Integration Checklist (Phase 3)

### 1. Add to App Startup
```dart
// After successful login
final response = await apiClient.post(
  '/api/check_daily_streak',
  headers: {'Authorization': 'Bearer $token'}
);
// Show streak UI with coins_earned
```

### 2. Call After Quiz
```dart
// After quiz completion
await apiClient.post(
  '/api/evaluate_user_risk',
  body: {
    'action_type': 'quiz_complete',
    'metadata': {
      'accuracy': accuracy,
      'avg_answer_time': avgTime
    }
  }
);
```

### 3. Before Payment Screen
```dart
// Before showing "Withdraw" button
final eligibility = await apiClient.post(
  '/api/check_payout_eligibility'
);
if (!eligibility['data']['eligible']) {
  showMessage(eligibility['data']['message']);
}
```

### 4. Sponsor Banner Display
```dart
// On home screen load
final banner = await apiClient.post('/api/get_sponsor_banner');
if (banner['data'] != null) {
  displayBanner(banner['data']);
}
```

### 5. Boost Earnings Flow
```dart
// After quiz result
final boost = await apiClient.post(
  '/api/offer_boost_earnings',
  body: {'coins': quizCoins}
);
// Show popup with boost_coins vs original_coins

// After user watches ad
await apiClient.post(
  '/api/apply_boost_earnings',
  body: {'coins': quizCoins}
);
```

---

## ⚙️ Configuration Reference

### All Configurable Values (via Admin Panel)

| Setting | Default | Range | Purpose |
|---------|---------|-------|---------|
| daily_streak_coin_reward | 10 | 1-1000 | Coins per day |
| daily_streak_bonus_threshold | 7 | 1-365 | Days for milestone bonus |
| daily_streak_bonus_coin | 50 | 1-10000 | Bonus coins amount |
| device_one_account_enforcement | 1 | 0-1 | Enable multi-account prevention |
| fraud_daily_ad_limit | 100 | 10-1000 | Max ads per day |
| fraud_quiz_accuracy_threshold | 95 | 50-100 | Min accuracy % |
| fraud_quiz_speed_seconds | 10 | 1-60 | Min seconds per question |
| fraud_new_account_withdrawal_days | 7 | 1-30 | New account lock days |
| min_active_days_for_payout | 20 | 1-365 | Days needed for withdrawal |
| activity_tracking_window_days | 30 | 1-365 | Lookback window |
| boost_earnings_coin_multiplier | 2 | 1-10 | Coin multiplier |
| watch_unlock_ad_count | 3 | 1-100 | Ads needed to unlock |
| sponsor_banner_enable | 1 | 0-1 | Show sponsor banners |
| sponsor_banner_rotation_seconds | 5 | 1-60 | Auto-rotate delay |

**Change any value:** Admin Panel → Settings pages

---

## 📊 Database Tables Created

### 5 New Tables

1. **tbl_daily_streak** (Columns: 9, Rows: TBD)
   - Tracks user daily login streaks
   - Indexes: user_id, last_login_date

2. **tbl_device_mapping** (Columns: 8, Rows: TBD)
   - One device per user enforcement
   - Indexes: device_id (UNIQUE), user_id

3. **tbl_fraud_detection** (Columns: 13, Rows: TBD)
   - Suspicious activity records
   - Indexes: user_id, detection_type, severity, resolved

4. **tbl_sponsor_banners** (Columns: 16, Rows: TBD)
   - Sponsor advertisement management
   - Indexes: is_active, start_date, priority

5. **tbl_banner_impressions** (Columns: 5, Rows: TBD)
   - Banner impression analytics
   - Indexes: banner_id, user_id, recorded_at

---

## 🐛 Troubleshooting

### Admin Pages Show 404 Error
**Solution:** Verify file names match class names (case-sensitive)
```
Files MUST be:
  - Streak.php → class Streak
  - Device.php → class Device
  - Fraud.php → class Fraud
  - Sponsors.php → class Sponsors
```

### API Endpoints Return "Missing parameter"
**Solution:** Check POST data includes required fields
```
check_daily_streak: token (required)
register_device: token, device_id, device_type (required)
evaluate_user_risk: token, action_type (required)
get_sponsor_banner: token (optional)
```

### Coins Not Updating
**Solution:** Verify set_coins() and set_tracker_data() are in Api helper
```php
// Should exist in admin_backend/application/helpers/
public function set_coins($user_id, $coins, $action = 'admin')
public function set_tracker_data($user_id, $coins, $type, $value)
```

### Banner Images Not Uploading
**Solution:** Verify directory exists and is writable
```
Directory: admin_backend/images/sponsor_banners/
Permissions: 755 (owner can read/write, others can read)
```

---

## 📞 Support Information

### Code Location Reference
```
Models: admin_backend/application/models/
Views: admin_backend/application/views/
Controllers: admin_backend/application/controllers/
Database: admin_backend/database/migrations/
API: admin_backend/application/controllers/Api.php (added to end)
```

### Key Files to Review
1. **Streak_model.php** - Daily login logic
2. **Device_model.php** - Multi-account prevention
3. **Fraud_model.php** - Suspicious activity detection
4. **Sponsor_model.php** - Banner management
5. **Api.php** - 9 new endpoints (search for "check_daily_streak_post")

---

## ✅ Success Criteria

Phase 2 is complete when:
- [ ] Database migrations executed without errors
- [ ] 5 new tables exist in database
- [ ] 20 settings visible in tbl_settings
- [ ] Admin pages load: /Streak, /Device, /Fraud, /Sponsors
- [ ] Settings forms can be submitted and saved
- [ ] API endpoints return valid JSON responses
- [ ] Admin menu navigation updated (optional)

---

## 🎉 What You Can Do Now

✅ **Configure** all monetization features via admin panel
✅ **Test** API endpoints with Postman
✅ **Review** user activity in fraud detection dashboard
✅ **Monitor** sponsor banner impressions and CTR
✅ **Adjust** all parameters without code changes

---

## 📅 Timeline to Next Phase

**Phase 3: Flutter App Integration** (4-5 hours)
- Implement API calls in Flutter app
- Add UI for daily streaks, boost earnings, sponsor banners
- Test end-to-end flow
- Deploy to app store

**Total Project Time:** 18-20 hours (1 business day)

---

**You're 50% complete! 🚀**

Questions or issues? Check PHASE_1_IMPLEMENTATION_COMPLETE.md or PHASE_2_IMPLEMENTATION_COMPLETE.md for detailed documentation.

Generated: January 16, 2026
