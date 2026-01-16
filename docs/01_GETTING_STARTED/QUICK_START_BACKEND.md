# 🚀 Quick Start: Backend Integration (5-Step Guide)

## What This Does
Allows you to manage App Open & Rewarded Interstitial ad unit IDs via admin panel (no app updates needed).

---

## ⚡ 5-Minute Setup

### Step 1: Run SQL (2 minutes)
```bash
# Open phpMyAdmin → Select database → SQL tab → Paste:
```
```sql
INSERT INTO `tbl_settings` (`type`, `message`, `description`) VALUES 
('app_open_id_android', 'ca-app-pub-3940256099942544/9257395921', 'Android App Open Ad'),
('app_open_id_ios', 'ca-app-pub-3940256099942544/5575463023', 'iOS App Open Ad'),
('rewarded_interstitial_id_android', 'ca-app-pub-3940256099942544/5354046379', 'Android Rewarded Interstitial'),
('rewarded_interstitial_id_ios', 'ca-app-pub-3940256099942544/6978759866', 'iOS Rewarded Interstitial');
```

### Step 2: Update Admin View (10 minutes)
**File**: `admin_backend/application/views/ads_settings.php`

**Add after `ios_game_id` field:**
```php
<div class="form-group">
    <label>App Open Ad ID - Android</label>
    <input type="text" class="form-control" name="app_open_id_android" 
           value="<?= isset($app_open_id_android['message']) ? $app_open_id_android['message'] : '' ?>">
</div>
<!-- Repeat for: app_open_id_ios, rewarded_interstitial_id_android, rewarded_interstitial_id_ios -->
```

### Step 3: Get Real Ad IDs (15 minutes)
1. Visit: https://apps.admob.com
2. Select "mQuiz" app
3. Add ad unit → App open → Android → Copy ID
4. Repeat for iOS, Rewarded Interstitial (Android + iOS)

### Step 4: Update IDs (2 minutes)
Admin Panel → Settings → Ads Settings → Paste 4 real ad unit IDs → Save

### Step 5: Test (5 minutes)
```bash
# Check API response:
https://yourdomain.com/admin_backend/Api/get_system_configurations

# Run Flutter app:
flutter run

# Look for logs:
✅ "Loading app open ad with ID: ca-app-pub-..."
```

---

## ✅ What's Already Done

All code changes are complete:
- ✅ Backend API updated (Api.php)
- ✅ Backend controller updated (Settings.php)
- ✅ Flutter model updated (system_config_model.dart)
- ✅ Flutter cubits updated (system_config_cubit.dart)
- ✅ Ad cubits updated (app_open_ad_cubit.dart, rewarded_interstitial_ad_cubit.dart)

**You only need to:**
1. Run SQL commands
2. Add HTML fields to admin view
3. Get real ad IDs from AdMob
4. Enter IDs in admin panel

---

## 📊 Expected Results

| Metric | Before | After | Increase |
|--------|--------|-------|----------|
| **Daily Revenue** (5 DAU) | $0.034 | $0.064-0.091 | **+88-167%** |
| **Yearly Revenue** | $12.48 | $23.43-33.29 | **+$10.95-20.81** |
| **Ad Formats** | 3 | 5 | +2 premium formats |

---

## 🆘 Quick Troubleshooting

| Problem | Solution |
|---------|----------|
| SQL error | Check table is `tbl_settings` (not `settings`) |
| Admin fields not saving | Clear browser cache, verify form `name` attributes |
| App shows test IDs | Wait 5 min for API cache, restart app |
| Ads not showing | Wait 4 hours between app open ads (frequency cap) |

---

## 📚 Full Documentation

- **Complete Guide**: [BACKEND_SQL_AND_ADMIN_SETUP.md](./BACKEND_SQL_AND_ADMIN_SETUP.md)
- **Admin View HTML**: [ADMIN_VIEW_UPDATE_GUIDE.md](./ADMIN_VIEW_UPDATE_GUIDE.md)
- **SQL Script**: [database_updates_new_ads.sql](./database_updates_new_ads.sql)
- **Summary**: [SETUP_SUMMARY.md](./SETUP_SUMMARY.md)

---

## 🎯 Success Checklist

- [ ] SQL commands executed (4 rows in database)
- [ ] Admin view has 4 new input fields
- [ ] AdMob console has 4 new ad units created
- [ ] Admin panel shows 4 new fields with real IDs
- [ ] API returns 4 new keys in JSON
- [ ] Flutter app logs show real ad unit IDs (not test IDs)
- [ ] App open ad displays on launch
- [ ] Rewarded interstitial ad offer appears after quizzes

**Total Time**: 35-45 minutes  
**Difficulty**: Easy (SQL + HTML + Config)  
**Impact**: +$10-21/year at current scale 🚀

---

**Need help?** Check [BACKEND_SQL_AND_ADMIN_SETUP.md](./BACKEND_SQL_AND_ADMIN_SETUP.md) for detailed troubleshooting.
