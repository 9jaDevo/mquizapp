# Backend Setup for New Ad Formats

## Quick Checklist

### 1. Get Ad Unit IDs from AdMob Console ✅

**Steps**:
1. Visit [AdMob Console](https://apps.admob.com)
2. Select "mQuiz" app
3. Go to **Ad units** → **Add ad unit**

**Create App Open Ad Unit**:
```
Format: App open
Name: mQuiz App Open - Android
Platform: Android

→ Copy ad unit ID: ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
```

Repeat for iOS:
```
Format: App open
Name: mQuiz App Open - iOS
Platform: iOS

→ Copy ad unit ID: ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
```

**Create Rewarded Interstitial Ad Unit**:
```
Format: Rewarded interstitial
Name: mQuiz Rewarded Interstitial - Android
Platform: Android

→ Copy ad unit ID: ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
```

Repeat for iOS:
```
Format: Rewarded interstitial
Name: mQuiz Rewarded Interstitial - iOS
Platform: iOS

→ Copy ad unit ID: ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX
```

---

### 2. Add to Backend Database ✅

**SQL Commands** (run in your MySQL/phpMyAdmin):

```sql
-- Add new settings for App Open ads
INSERT INTO `settings` (`type`, `message`, `description`) 
VALUES 
('app_open_id_android', 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX', 'Android App Open Ad Unit ID'),
('app_open_id_ios', 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX', 'iOS App Open Ad Unit ID');

-- Add new settings for Rewarded Interstitial ads
INSERT INTO `settings` (`type`, `message`, `description`) 
VALUES 
('rewarded_interstitial_id_android', 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX', 'Android Rewarded Interstitial Ad Unit ID'),
('rewarded_interstitial_id_ios', 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX', 'iOS Rewarded Interstitial Ad Unit ID');
```

Replace the placeholder IDs (`ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX`) with real IDs from Step 1.

---

### 3. Update Backend API ✅

**File**: `admin_backend/application/controllers/Api.php`

**Find**: `public function get_system_configurations()` method (around line 200-400)

**Add** these lines to the response array (where other ad IDs are defined):

```php
'app_open_id_android' => $this->db
    ->get_where('settings', ['type' => 'app_open_id_android'])
    ->row()
    ->message ?? '',

'app_open_id_ios' => $this->db
    ->get_where('settings', ['type' => 'app_open_id_ios'])
    ->row()
    ->message ?? '',

'rewarded_interstitial_id_android' => $this->db
    ->get_where('settings', ['type' => 'rewarded_interstitial_id_android'])
    ->row()
    ->message ?? '',

'rewarded_interstitial_id_ios' => $this->db
    ->get_where('settings', ['type' => 'rewarded_interstitial_id_ios'])
    ->row()
    ->message ?? '',
```

---

### 4. Test Backend API ✅

**Browser Test**:
```
https://your-domain.com/api/get_system_configurations

Search for:
- "app_open_id_android": "ca-app-pub-..."
- "app_open_id_ios": "ca-app-pub-..."
- "rewarded_interstitial_id_android": "ca-app-pub-..."
- "rewarded_interstitial_id_ios": "ca-app-pub-..."
```

If these fields appear in JSON response → Backend is ready ✅

---

### 5. Update Flutter Model (Optional - for dynamic config) ✅

**File**: `lib/features/system_config/model/system_config_model.dart`

**Add** fields to constructor (around line 20):
```dart
required this.appOpenIdAndroid,
required this.appOpenIdIos,
required this.rewardedInterstitialIdAndroid,
required this.rewardedInterstitialIdIos,
```

**Add** field declarations (around line 100):
```dart
final String appOpenIdAndroid;
final String appOpenIdIos;
final String rewardedInterstitialIdAndroid;
final String rewardedInterstitialIdIos;
```

**Add** JSON parsing (in `fromJson` constructor, around line 150):
```dart
appOpenIdAndroid = json['app_open_id_android'] as String? ?? '',
appOpenIdIos = json['app_open_id_ios'] as String? ?? '',
rewardedInterstitialIdAndroid = json['rewarded_interstitial_id_android'] as String? ?? '',
rewardedInterstitialIdIos = json['rewarded_interstitial_id_ios'] as String? ?? '',
```

---

### 6. Update Ad Cubits to Use Backend IDs ✅

**File**: `lib/features/ads/blocs/app_open_ad_cubit.dart`

**Replace** (around line 92-95):
```dart
// OLD (test ID):
final testAdUnitId = Platform.isAndroid
    ? 'ca-app-pub-3940256099942544/9257395921'
    : 'ca-app-pub-3940256099942544/5575463023';

// NEW (backend ID):
final adUnitId = Platform.isAndroid
    ? config.appOpenIdAndroid
    : config.appOpenIdIos;
```

**File**: `lib/features/ads/blocs/rewarded_interstitial_ad_cubit.dart`

**Replace** (around line 63-66):
```dart
// OLD (test ID):
final testAdUnitId = Platform.isAndroid
    ? 'ca-app-pub-3940256099942544/5354046379'
    : 'ca-app-pub-3940256099942544/6978759866';

// NEW (backend ID):
final adUnitId = Platform.isAndroid
    ? config.rewardedInterstitialIdAndroid
    : config.rewardedInterstitialIdIos;
```

---

## Summary

### What You Need from AdMob Console:
- [ ] Android App Open Ad Unit ID
- [ ] iOS App Open Ad Unit ID
- [ ] Android Rewarded Interstitial Ad Unit ID
- [ ] iOS Rewarded Interstitial Ad Unit ID

### What You Need to Update:
- [ ] Backend database (settings table)
- [ ] Backend API controller (Api.php)
- [ ] Flutter system config model (system_config_model.dart)
- [ ] App open ad cubit (app_open_ad_cubit.dart)
- [ ] Rewarded interstitial ad cubit (rewarded_interstitial_ad_cubit.dart)

### Time Estimate:
- AdMob Console: 10 minutes
- Backend Database: 5 minutes
- Backend API: 5 minutes
- Flutter Code: 10 minutes
- **Total: ~30 minutes**

---

## Alternative: Keep Using Test IDs (for now)

If you want to test first before adding to backend:

**Current state**: Already using test IDs (safe for development)
**Limitation**: Test ads don't generate real revenue
**Action**: Deploy with test IDs → Verify everything works → Then add real IDs

**Note**: App will work perfectly with test IDs. Only difference is $0 revenue. Real ads will show once you swap in production IDs.

---

## Questions?

- **Where is my AdMob app ID?** Check `AndroidManifest.xml` line 37 or `Info.plist` (iOS)
- **How do I know if backend is updated?** Visit `/api/get_system_configurations` in browser
- **Can I test without real IDs?** Yes, current test IDs work fine for testing
- **Will test ads show on my phone?** Yes, if you register as test device in AdMob console

---

## Next Steps After Backend Setup:

1. Build new APK with real ad unit IDs
2. Test on physical device
3. Monitor AdMob console for impressions
4. Check metrics with `AdAnalyticsCollector.generateDailyReport()`
5. Adjust frequency caps if needed

**That's it! Your app is now ready for 2x revenue increase! 🚀**
