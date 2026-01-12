-- ========================================
-- Database Updates for New Ad Formats
-- App Open Ads + Rewarded Interstitial Ads
-- ========================================
-- 
-- Run these SQL commands in phpMyAdmin or MySQL terminal
-- to add new ad unit settings to your backend
--
-- IMPORTANT: Replace test ad unit IDs with your real AdMob IDs
-- Get real IDs from: https://apps.admob.com
-- ========================================

-- Add new settings for App Open ads
INSERT INTO `tbl_settings` (`type`, `message`, `description`) 
VALUES 
(
    'app_open_id_android', 
    'ca-app-pub-3940256099942544/9257395921', 
    'Android App Open Ad Unit ID from AdMob Console'
),
(
    'app_open_id_ios', 
    'ca-app-pub-3940256099942544/5575463023', 
    'iOS App Open Ad Unit ID from AdMob Console'
);

-- Add new settings for Rewarded Interstitial ads
INSERT INTO `tbl_settings` (`type`, `message`, `description`) 
VALUES 
(
    'rewarded_interstitial_id_android', 
    'ca-app-pub-3940256099942544/5354046379', 
    'Android Rewarded Interstitial Ad Unit ID from AdMob Console'
),
(
    'rewarded_interstitial_id_ios', 
    'ca-app-pub-3940256099942544/6978759866', 
    'iOS Rewarded Interstitial Ad Unit ID from AdMob Console'
);

-- ========================================
-- Verify the settings were added
-- ========================================
SELECT * FROM tbl_settings 
WHERE type LIKE '%app_open%' 
   OR type LIKE '%rewarded_interstitial%';

-- Expected output: 4 rows
-- 1. app_open_id_android
-- 2. app_open_id_ios
-- 3. rewarded_interstitial_id_android
-- 4. rewarded_interstitial_id_ios

-- ========================================
-- OPTIONAL: Update with your real ad unit IDs
-- ========================================
-- Replace XXXXXXXXXXXXXXXX and XXXXXXXXXX with your actual AdMob ad unit IDs

-- UPDATE tbl_settings SET message = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX' 
-- WHERE type = 'app_open_id_android';

-- UPDATE tbl_settings SET message = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX' 
-- WHERE type = 'app_open_id_ios';

-- UPDATE tbl_settings SET message = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX' 
-- WHERE type = 'rewarded_interstitial_id_android';

-- UPDATE tbl_settings SET message = 'ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX' 
-- WHERE type = 'rewarded_interstitial_id_ios';

-- ========================================
-- How to get real ad unit IDs:
-- ========================================
-- 1. Visit https://apps.admob.com
-- 2. Select your "mQuiz" app
-- 3. Click "Ad units" → "Add ad unit"
--
-- Create App Open Ad Unit (Android):
--   - Format: App open
--   - Name: mQuiz App Open - Android
--   - Platform: Android
--   - Copy the generated ad unit ID
--
-- Create App Open Ad Unit (iOS):
--   - Format: App open
--   - Name: mQuiz App Open - iOS
--   - Platform: iOS
--   - Copy the generated ad unit ID
--
-- Create Rewarded Interstitial Ad Unit (Android):
--   - Format: Rewarded interstitial
--   - Name: mQuiz Rewarded Interstitial - Android
--   - Platform: Android
--   - Copy the generated ad unit ID
--
-- Create Rewarded Interstitial Ad Unit (iOS):
--   - Format: Rewarded interstitial
--   - Name: mQuiz Rewarded Interstitial - iOS
--   - Platform: iOS
--   - Copy the generated ad unit ID
--
-- ========================================
-- NOTES:
-- ========================================
-- * Test ad unit IDs are provided by default
-- * Test IDs will show test ads but generate NO REVENUE
-- * Replace with real IDs from AdMob console before production
-- * You can update IDs later via admin panel (Settings → Ads Settings)
-- * Changes take effect immediately via API (no app update needed)
-- ========================================
