# Backend SQL and Admin Panel Setup for New Ad Formats
## App Open Ads + Rewarded Interstitial Ads

---

## Step 1: Run SQL Commands in Database ✅

**Run these commands in phpMyAdmin or MySQL terminal:**

### Option A: Direct SQL (Recommended)

```sql
-- Add new settings for App Open ads
INSERT INTO `tbl_settings` (`type`, `message`, `description`) 
VALUES 
('app_open_id_android', 'ca-app-pub-3940256099942544/9257395921', 'Android App Open Ad Unit ID from AdMob Console'),
('app_open_id_ios', 'ca-app-pub-3940256099942544/5575463023', 'iOS App Open Ad Unit ID from AdMob Console');

-- Add new settings for Rewarded Interstitial ads
INSERT INTO `tbl_settings` (`type`, `message`, `description`) 
VALUES 
('rewarded_interstitial_id_android', 'ca-app-pub-3940256099942544/5354046379', 'Android Rewarded Interstitial Ad Unit ID from AdMob Console'),
('rewarded_interstitial_id_ios', 'ca-app-pub-3940256099942544/6978759866', 'iOS Rewarded Interstitial Ad Unit ID from AdMob Console');
```

**⚠️ IMPORTANT**: 
- Replace the test ad unit IDs above with **your real AdMob ad unit IDs** from the AdMob console
- Test IDs are provided by default but **will not generate revenue**
- Get real ad unit IDs from: https://apps.admob.com → Select "mQuiz" app → Ad units

---

## Step 2: Update Backend API Controller ✅

**File**: `admin_backend/application/controllers/Api.php`

**Location**: Around line 2425-2445 (in the `get_system_configurations_post()` method)

**Find this array:**
```php
$setting = [
    'system_timezone',
    'system_timezone_gmt',
    'app_link',
    'ios_app_link',
    'refer_coin',
    'earn_coin',
    'reward_coin',
    'app_version',
    'app_version_ios',
    'shareapp_text',
    'language_mode',
    'force_update',
    'daily_quiz_mode',
    'in_app_purchase_mode',
    'in_app_ads_mode',
    'ads_type',
    'android_banner_id',
    'android_interstitial_id',
    'android_rewarded_id',
    'ios_banner_id',
    'ios_interstitial_id',
    'ios_rewarded_id',
    'android_game_id',
    'ios_game_id',
    // ... more settings
```

**Add these 4 lines after `ios_game_id`:**
```php
    'ios_game_id',
    'app_open_id_android',           // NEW - App Open for Android
    'app_open_id_ios',                // NEW - App Open for iOS
    'rewarded_interstitial_id_android', // NEW - Rewarded Interstitial for Android
    'rewarded_interstitial_id_ios',    // NEW - Rewarded Interstitial for iOS
    'app_key_android_iron_source',
```

**Complete Updated Section:**
```php
'ads_type',
'android_banner_id',
'android_interstitial_id',
'android_rewarded_id',
'ios_banner_id',
'ios_interstitial_id',
'ios_rewarded_id',
'android_game_id',
'ios_game_id',
'app_open_id_android',           // ✅ NEW
'app_open_id_ios',                // ✅ NEW
'rewarded_interstitial_id_android', // ✅ NEW
'rewarded_interstitial_id_ios',    // ✅ NEW
'app_key_android_iron_source',
'app_key_ios_iron_source',
```

**Why**: The API will now return these 4 new ad unit IDs to your Flutter app automatically.

---

## Step 3: Update Admin Panel Settings Page ✅

**File**: `admin_backend/application/controllers/Settings.php`

**Location**: Around line 211-230 (in the `ads_settings()` method)

**Find this array:**
```php
$settings = [
    'in_app_ads_mode',
    'ads_type',
    'android_banner_id',
    'android_interstitial_id',
    'android_rewarded_id',
    'ios_banner_id',
    'ios_interstitial_id',
    'ios_rewarded_id',
    'android_game_id',
    'ios_game_id',
    'daily_ads_visibility',
    // ... more settings
```

**Add these 4 lines after `ios_game_id`:**
```php
    'ios_game_id',
    'app_open_id_android',           // NEW - App Open for Android
    'app_open_id_ios',                // NEW - App Open for iOS
    'rewarded_interstitial_id_android', // NEW - Rewarded Interstitial for Android
    'rewarded_interstitial_id_ios',    // NEW - Rewarded Interstitial for iOS
    'daily_ads_visibility',
```

**Complete Updated Section:**
```php
$settings = [
    'in_app_ads_mode',
    'ads_type',
    'android_banner_id',
    'android_interstitial_id',
    'android_rewarded_id',
    'ios_banner_id',
    'ios_interstitial_id',
    'ios_rewarded_id',
    'android_game_id',
    'ios_game_id',
    'app_open_id_android',           // ✅ NEW
    'app_open_id_ios',                // ✅ NEW
    'rewarded_interstitial_id_android', // ✅ NEW
    'rewarded_interstitial_id_ios',    // ✅ NEW
    'daily_ads_visibility',
    'daily_ads_coins',
    'daily_ads_counter',
    'reward_coin',
    'app_key_android_iron_source',
    'app_key_ios_iron_source',
    'rewarded_id_android_iron_source',
    'rewarded_id_ios_iron_source',
    'interstitial_id_android_iron_source',
    'interstitial_id_ios_iron_source',
    'banner_id_android_iron_source',
    'banner_id_ios_iron_source',
];
```

**Why**: This makes the new ad unit IDs editable in your admin panel under "Ads Settings" page.

---

## Step 4: Update Admin View (Frontend) ✅

**File**: `admin_backend/application/views/ads_settings.php`

You need to add 4 new input fields to the admin panel form. Find the section where ad IDs are displayed (usually where you see inputs for `android_banner_id`, `ios_banner_id`, etc.).

**Add these 4 input groups** (place them after the existing `ios_game_id` field):

```php
<!-- App Open Ad - Android -->
<div class="form-group">
    <label for="app_open_id_android">App Open Ad ID - Android</label>
    <input type="text" class="form-control" id="app_open_id_android" name="app_open_id_android" 
           value="<?= isset($app_open_id_android['message']) ? $app_open_id_android['message'] : '' ?>" 
           placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
    <small class="form-text text-muted">Get from AdMob Console → mQuiz → Ad units → App open (Android)</small>
</div>

<!-- App Open Ad - iOS -->
<div class="form-group">
    <label for="app_open_id_ios">App Open Ad ID - iOS</label>
    <input type="text" class="form-control" id="app_open_id_ios" name="app_open_id_ios" 
           value="<?= isset($app_open_id_ios['message']) ? $app_open_id_ios['message'] : '' ?>" 
           placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
    <small class="form-text text-muted">Get from AdMob Console → mQuiz → Ad units → App open (iOS)</small>
</div>

<!-- Rewarded Interstitial Ad - Android -->
<div class="form-group">
    <label for="rewarded_interstitial_id_android">Rewarded Interstitial Ad ID - Android</label>
    <input type="text" class="form-control" id="rewarded_interstitial_id_android" name="rewarded_interstitial_id_android" 
           value="<?= isset($rewarded_interstitial_id_android['message']) ? $rewarded_interstitial_id_android['message'] : '' ?>" 
           placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
    <small class="form-text text-muted">Get from AdMob Console → mQuiz → Ad units → Rewarded interstitial (Android)</small>
</div>

<!-- Rewarded Interstitial Ad - iOS -->
<div class="form-group">
    <label for="rewarded_interstitial_id_ios">Rewarded Interstitial Ad ID - iOS</label>
    <input type="text" class="form-control" id="rewarded_interstitial_id_ios" name="rewarded_interstitial_id_ios" 
           value="<?= isset($rewarded_interstitial_id_ios['message']) ? $rewarded_interstitial_id_ios['message'] : '' ?>" 
           placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
    <small class="form-text text-muted">Get from AdMob Console → mQuiz → Ad units → Rewarded interstitial (iOS)</small>
</div>
```

**Note**: You may need to adjust the exact PHP variable names based on your admin panel's structure. Look at how other ad ID fields are implemented in the same file.

---

## Step 5: Update Flutter Model to Parse New IDs ✅

**File**: `lib/features/system_config/model/system_config_model.dart`

### 5.1: Add Fields to Constructor

**Location**: Around line 20-30 (constructor parameters)

**Add:**
```dart
required this.appOpenIdAndroid,
required this.appOpenIdIos,
required this.rewardedInterstitialIdAndroid,
required this.rewardedInterstitialIdIos,
```

### 5.2: Declare Fields

**Location**: Around line 240-250 (after `androidRewardedId`)

**Add:**
```dart
final String androidBannerId;
final String androidGameID;
final String androidInterstitialId;
final String androidRewardedId;
final String appOpenIdAndroid;         // ✅ NEW
final String appOpenIdIos;              // ✅ NEW
final String rewardedInterstitialIdAndroid; // ✅ NEW
final String rewardedInterstitialIdIos;     // ✅ NEW
final AnswerMode answerMode;
```

### 5.3: Parse in `fromJson` Constructor

**Location**: Around line 106-115 (JSON parsing)

**Add:**
```dart
androidBannerId = json['android_banner_id'] as String? ?? '',
androidGameID = json['android_game_id'] as String? ?? '',
androidInterstitialId = json['android_interstitial_id'] as String? ?? '',
androidRewardedId = json['android_rewarded_id'] as String? ?? '',
appOpenIdAndroid = json['app_open_id_android'] as String? ?? '',         // ✅ NEW
appOpenIdIos = json['app_open_id_ios'] as String? ?? '',                  // ✅ NEW
rewardedInterstitialIdAndroid = json['rewarded_interstitial_id_android'] as String? ?? '', // ✅ NEW
rewardedInterstitialIdIos = json['rewarded_interstitial_id_ios'] as String? ?? '',     // ✅ NEW
iosAppLink = json['ios_app_link'] as String? ?? '',
```

---

## Step 6: Add Getters to SystemConfigCubit ✅

**File**: `lib/features/system_config/cubits/system_config_cubit.dart`

**Location**: Around line 157-165 (after `googleRewardedAdId`)

**Add:**
```dart
String get googleRewardedAdId => Platform.isIOS
    ? systemConfigModel?.iosRewardedId ?? ''
    : systemConfigModel?.androidRewardedId ?? '';

String get appOpenAdId => Platform.isIOS            // ✅ NEW
    ? systemConfigModel?.appOpenIdIos ?? ''
    : systemConfigModel?.appOpenIdAndroid ?? '';

String get rewardedInterstitialAdId => Platform.isIOS  // ✅ NEW
    ? systemConfigModel?.rewardedInterstitialIdIos ?? ''
    : systemConfigModel?.rewardedInterstitialIdAndroid ?? '';

bool get isForceUpdateEnable => systemConfigModel?.forceUpdate ?? false;
```

---

## Step 7: Update Ad Cubits to Use Backend IDs ✅

### 7.1: App Open Ad Cubit

**File**: `lib/features/ads/blocs/app_open_ad_cubit.dart`

**Location**: Around line 92-95

**Replace:**
```dart
// ❌ OLD (test ID):
final testAdUnitId = Platform.isAndroid
    ? 'ca-app-pub-3940256099942544/9257395921'
    : 'ca-app-pub-3940256099942544/5575463023';

await AppOpenAd.load(
  adUnitId: testAdUnitId,  // ❌ REMOVE THIS
```

**With:**
```dart
// ✅ NEW (backend ID):
final adUnitId = config.appOpenAdId;

if (adUnitId.isEmpty) {
  log('App open ad unit ID not configured in backend', name: 'AppOpenAd');
  emit(AppOpenAdState.initial);
  return;
}

await AppOpenAd.load(
  adUnitId: adUnitId,  // ✅ USE BACKEND ID
```

### 7.2: Rewarded Interstitial Ad Cubit

**File**: `lib/features/ads/blocs/rewarded_interstitial_ad_cubit.dart`

**Location**: Around line 63-66

**Replace:**
```dart
// ❌ OLD (test ID):
final testAdUnitId = Platform.isAndroid
    ? 'ca-app-pub-3940256099942544/5354046379'
    : 'ca-app-pub-3940256099942544/6978759866';

await RewardedInterstitialAd.load(
  adUnitId: testAdUnitId,  // ❌ REMOVE THIS
```

**With:**
```dart
// ✅ NEW (backend ID):
final adUnitId = config.rewardedInterstitialAdId;

if (adUnitId.isEmpty) {
  log('Rewarded interstitial ad unit ID not configured in backend', name: 'RewardedInterstitialAd');
  emit(RewardedInterstitialAdState.initial);
  return;
}

await RewardedInterstitialAd.load(
  adUnitId: adUnitId,  // ✅ USE BACKEND ID
```

---

## Testing Checklist ✅

### Database Test:
```sql
-- Verify settings were added:
SELECT * FROM tbl_settings WHERE type LIKE '%app_open%' OR type LIKE '%rewarded_interstitial%';

-- Expected output: 4 rows
-- app_open_id_android
-- app_open_id_ios
-- rewarded_interstitial_id_android
-- rewarded_interstitial_id_ios
```

### Admin Panel Test:
1. Login to admin panel
2. Go to **Settings** → **Ads Settings**
3. Verify you see 4 new input fields:
   - App Open Ad ID - Android
   - App Open Ad ID - iOS
   - Rewarded Interstitial Ad ID - Android
   - Rewarded Interstitial Ad ID - iOS
4. Enter your real AdMob ad unit IDs
5. Click **Save**
6. Reload page and verify IDs are saved

### API Test:
1. Open: `https://yourdomain.com/admin_backend/Api/get_system_configurations`
2. Look for these fields in JSON response:
```json
{
  "app_open_id_android": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
  "app_open_id_ios": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
  "rewarded_interstitial_id_android": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX",
  "rewarded_interstitial_id_ios": "ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX"
}
```

### Flutter App Test:
1. Run app in debug mode
2. Check terminal for logs:
   - "Loading app open ad" (app launch)
   - "Loading rewarded interstitial ad" (when triggered)
3. Verify no errors about "ad unit ID not configured"
4. Test ad display (use test IDs first, then switch to real IDs)

---

## Getting Real Ad Unit IDs from AdMob Console 🎯

1. Visit: https://apps.admob.com
2. Select your **mQuiz** app
3. Click **Ad units** → **Add ad unit**

### Create App Open Ad Unit (Android):
- Format: **App open**
- Name: `mQuiz App Open - Android`
- Platform: **Android**
- Copy the generated ad unit ID (format: `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`)

### Create App Open Ad Unit (iOS):
- Format: **App open**
- Name: `mQuiz App Open - iOS`
- Platform: **iOS**
- Copy the generated ad unit ID

### Create Rewarded Interstitial Ad Unit (Android):
- Format: **Rewarded interstitial**
- Name: `mQuiz Rewarded Interstitial - Android`
- Platform: **Android**
- Copy the generated ad unit ID

### Create Rewarded Interstitial Ad Unit (iOS):
- Format: **Rewarded interstitial**
- Name: `mQuiz Rewarded Interstitial - iOS`
- Platform: **iOS**
- Copy the generated ad unit ID

**Then:**
- Update SQL with real IDs (re-run INSERT or UPDATE statements)
- OR update via admin panel (Settings → Ads Settings)

---

## Quick SQL Alternative: Update Existing Records

If you already ran the INSERT commands with test IDs, update them:

```sql
-- Update with your real AdMob ad unit IDs
UPDATE tbl_settings SET message = 'ca-app-pub-YOUR_REAL_ID_HERE/ANDROID_APP_OPEN' 
WHERE type = 'app_open_id_android';

UPDATE tbl_settings SET message = 'ca-app-pub-YOUR_REAL_ID_HERE/IOS_APP_OPEN' 
WHERE type = 'app_open_id_ios';

UPDATE tbl_settings SET message = 'ca-app-pub-YOUR_REAL_ID_HERE/ANDROID_REWARDED_INTERSTITIAL' 
WHERE type = 'rewarded_interstitial_id_android';

UPDATE tbl_settings SET message = 'ca-app-pub-YOUR_REAL_ID_HERE/IOS_REWARDED_INTERSTITIAL' 
WHERE type = 'rewarded_interstitial_id_ios';
```

---

## Summary of Changes

| Component | File | What Changed |
|-----------|------|--------------|
| **Database** | MySQL | Added 4 new settings rows in `tbl_settings` |
| **Backend API** | `Api.php` | Added 4 new keys to API response array |
| **Admin Controller** | `Settings.php` | Added 4 new settings to `ads_settings()` array |
| **Admin View** | `ads_settings.php` | Added 4 new input fields in form |
| **Flutter Model** | `system_config_model.dart` | Added 4 new fields + parsing |
| **Flutter Cubit** | `system_config_cubit.dart` | Added 2 new getters |
| **App Open Cubit** | `app_open_ad_cubit.dart` | Replaced test ID with `config.appOpenAdId` |
| **Rewarded Int. Cubit** | `rewarded_interstitial_ad_cubit.dart` | Replaced test ID with `config.rewardedInterstitialAdId` |

---

## Expected Revenue Impact 📊

**With 5 Daily Active Users:**

| Ad Format | eCPM | Daily Impressions | Daily Revenue | Yearly Revenue |
|-----------|------|------------------|---------------|----------------|
| **App Open** | $8-15 | ~3 | $0.024-0.045 | $8.76-16.43 |
| **Rewarded Interstitial** | $3-6 | ~2 | $0.006-0.012 | $2.19-4.38 |
| **Combined New Formats** | - | ~5 | $0.030-0.057 | **$10.95-20.81/year** |
| **Existing Ads** | - | - | ~$0.034/day | $12.48/year |
| **TOTAL** | - | - | ~$0.064-0.091/day | **$23.43-33.29/year** |

**Revenue Increase**: +88% to +167% 🚀

**At 50 DAU**: ~$234-333/year  
**At 500 DAU**: ~$2,340-3,330/year

---

## Support

If you encounter any issues:
1. Check error logs in `admin_backend/application/logs/`
2. Verify database connection and table structure
3. Test API endpoint directly in browser
4. Check Flutter terminal for error messages
5. Ensure AdMob ad unit IDs are correctly formatted

**Need more help?** Refer to:
- [APP_OPEN_REWARDED_INTERSTITIAL_GUIDE.md](./APP_OPEN_REWARDED_INTERSTITIAL_GUIDE.md)
- [BACKEND_SETUP_FOR_NEW_ADS.md](./BACKEND_SETUP_FOR_NEW_ADS.md)
- [AdMob Help Center](https://support.google.com/admob)

---

**✅ Ready to Deploy!**

Once all steps are completed, your app will:
- Load ad unit IDs dynamically from your backend
- Allow you to change ad IDs via admin panel (no app updates needed)
- Display App Open ads on launch/resume
- Show Rewarded Interstitial ads with higher rewards
- Generate significantly more ad revenue 🎉
