# Admin Panel View Update Guide
## Adding Ad Unit ID Fields to Ads Settings Page

---

## File to Edit: `admin_backend/application/views/ads_settings.php`

### Step 1: Locate the Existing Ad ID Fields

Find the section in your `ads_settings.php` file where existing ad unit IDs are displayed. It should look similar to this:

```php
<!-- Example of existing field -->
<div class="form-group row">
    <label class="col-md-4" for="android_banner_id">Android Banner ID</label>
    <div class="col-md-8">
        <input type="text" class="form-control" name="android_banner_id" 
               value="<?= isset($android_banner_id['message']) ? $android_banner_id['message'] : '' ?>">
    </div>
</div>
```

### Step 2: Add New Fields for App Open Ads

**After the `ios_game_id` field**, add these 4 new input fields:

```php
<!-- App Open Ad - Android -->
<div class="form-group row">
    <label class="col-md-4" for="app_open_id_android">
        <?= lang('app_open_ad_id_android'); ?>
        <small class="text-muted d-block">App Open Ad ID - Android</small>
    </label>
    <div class="col-md-8">
        <input type="text" class="form-control" id="app_open_id_android" 
               name="app_open_id_android" 
               value="<?= isset($app_open_id_android['message']) ? $app_open_id_android['message'] : '' ?>" 
               placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
        <small class="form-text text-muted">
            Get from AdMob Console → mQuiz → Ad units → App open (Android)
        </small>
    </div>
</div>

<!-- App Open Ad - iOS -->
<div class="form-group row">
    <label class="col-md-4" for="app_open_id_ios">
        <?= lang('app_open_ad_id_ios'); ?>
        <small class="text-muted d-block">App Open Ad ID - iOS</small>
    </label>
    <div class="col-md-8">
        <input type="text" class="form-control" id="app_open_id_ios" 
               name="app_open_id_ios" 
               value="<?= isset($app_open_id_ios['message']) ? $app_open_id_ios['message'] : '' ?>" 
               placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
        <small class="form-text text-muted">
            Get from AdMob Console → mQuiz → Ad units → App open (iOS)
        </small>
    </div>
</div>

<!-- Rewarded Interstitial Ad - Android -->
<div class="form-group row">
    <label class="col-md-4" for="rewarded_interstitial_id_android">
        <?= lang('rewarded_interstitial_ad_id_android'); ?>
        <small class="text-muted d-block">Rewarded Interstitial ID - Android</small>
    </label>
    <div class="col-md-8">
        <input type="text" class="form-control" id="rewarded_interstitial_id_android" 
               name="rewarded_interstitial_id_android" 
               value="<?= isset($rewarded_interstitial_id_android['message']) ? $rewarded_interstitial_id_android['message'] : '' ?>" 
               placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
        <small class="form-text text-muted">
            Get from AdMob Console → mQuiz → Ad units → Rewarded interstitial (Android)
        </small>
    </div>
</div>

<!-- Rewarded Interstitial Ad - iOS -->
<div class="form-group row">
    <label class="col-md-4" for="rewarded_interstitial_id_ios">
        <?= lang('rewarded_interstitial_ad_id_ios'); ?>
        <small class="text-muted d-block">Rewarded Interstitial ID - iOS</small>
    </label>
    <div class="col-md-8">
        <input type="text" class="form-control" id="rewarded_interstitial_id_ios" 
               name="rewarded_interstitial_id_ios" 
               value="<?= isset($rewarded_interstitial_id_ios['message']) ? $rewarded_interstitial_id_ios['message'] : '' ?>" 
               placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
        <small class="form-text text-muted">
            Get from AdMob Console → mQuiz → Ad units → Rewarded interstitial (iOS)
        </small>
    </div>
</div>
```

---

## Alternative: Simpler HTML Structure

If your admin panel uses a simpler structure without `lang()` helper:

```php
<!-- App Open Ad - Android -->
<div class="form-group">
    <label for="app_open_id_android">App Open Ad ID - Android</label>
    <input type="text" class="form-control" id="app_open_id_android" 
           name="app_open_id_android" 
           value="<?= isset($app_open_id_android['message']) ? $app_open_id_android['message'] : '' ?>" 
           placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
    <small class="form-text text-muted">
        Get from AdMob Console → mQuiz → Ad units → App open (Android)
    </small>
</div>

<!-- App Open Ad - iOS -->
<div class="form-group">
    <label for="app_open_id_ios">App Open Ad ID - iOS</label>
    <input type="text" class="form-control" id="app_open_id_ios" 
           name="app_open_id_ios" 
           value="<?= isset($app_open_id_ios['message']) ? $app_open_id_ios['message'] : '' ?>" 
           placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
    <small class="form-text text-muted">
        Get from AdMob Console → mQuiz → Ad units → App open (iOS)
    </small>
</div>

<!-- Rewarded Interstitial Ad - Android -->
<div class="form-group">
    <label for="rewarded_interstitial_id_android">Rewarded Interstitial Ad ID - Android</label>
    <input type="text" class="form-control" id="rewarded_interstitial_id_android" 
           name="rewarded_interstitial_id_android" 
           value="<?= isset($rewarded_interstitial_id_android['message']) ? $rewarded_interstitial_id_android['message'] : '' ?>" 
           placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
    <small class="form-text text-muted">
        Get from AdMob Console → mQuiz → Ad units → Rewarded interstitial (Android)
    </small>
</div>

<!-- Rewarded Interstitial Ad - iOS -->
<div class="form-group">
    <label for="rewarded_interstitial_id_ios">Rewarded Interstitial Ad ID - iOS</label>
    <input type="text" class="form-control" id="rewarded_interstitial_id_ios" 
           name="rewarded_interstitial_id_ios" 
           value="<?= isset($rewarded_interstitial_id_ios['message']) ? $rewarded_interstitial_id_ios['message'] : '' ?>" 
           placeholder="ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX">
    <small class="form-text text-muted">
        Get from AdMob Console → mQuiz → Ad units → Rewarded interstitial (iOS)
    </small>
</div>
```

---

## Important Notes:

1. **Variable Names**: The PHP variables must match the keys from Settings.php controller:
   - `$app_open_id_android`
   - `$app_open_id_ios`
   - `$rewarded_interstitial_id_android`
   - `$rewarded_interstitial_id_ios`

2. **Input Names**: The `name` attributes must match the database types:
   - `name="app_open_id_android"`
   - `name="app_open_id_ios"`
   - `name="rewarded_interstitial_id_android"`
   - `name="rewarded_interstitial_id_ios"`

3. **Form Structure**: Make sure to add these fields inside the existing `<form>` tag, typically between the Unity/IronSource ad fields section.

4. **CSS Classes**: Adjust `col-md-4`, `col-md-8`, etc. based on your existing admin panel's Bootstrap grid system.

---

## Testing:

After adding the fields:

1. Clear browser cache
2. Refresh the admin panel
3. Navigate to **Settings** → **Ads Settings**
4. Verify the 4 new fields appear
5. Enter test ad unit IDs
6. Click Save
7. Reload page and verify values are saved

---

## Optional: Add Section Header

You can add a section header to group the new ad formats:

```php
<hr>
<h5 class="mb-3">Premium Ad Formats (AdMob Only)</h5>

<!-- Then add the 4 fields here -->
```

---

## Need Help?

If you can't find the `ads_settings.php` file or the structure is different:

1. Check: `admin_backend/application/views/ads_settings.php`
2. Look for similar files like `ad_settings.php` or `advertising_settings.php`
3. Search for where `android_banner_id` is displayed
4. Match the HTML structure of existing fields
5. Refer to [BACKEND_SQL_AND_ADMIN_SETUP.md](./BACKEND_SQL_AND_ADMIN_SETUP.md) for complete setup guide
