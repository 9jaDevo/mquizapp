-- =====================================================================
-- MONETIZATION FEATURES SETUP - REQUIRED FOR HOME SCREEN DISPLAY
-- =====================================================================
-- This file sets up:
-- 1. Database tables for daily streaks and sponsor banners
-- 2. Settings for monetization features
-- 3. Test sponsor banner data
--
-- RUN THIS IN YOUR DATABASE (phpMyAdmin or MySQL)
-- =====================================================================

-- ============================================================
-- STEP 1: Create Tables (if they don't exist)
-- ============================================================

-- Daily Streak Table
CREATE TABLE IF NOT EXISTS `tbl_daily_streak` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `uid` VARCHAR(255),
    `last_login_date` DATE,
    `streak_count` INT DEFAULT 0 COMMENT 'Current active streak days',
    `max_streak` INT DEFAULT 0 COMMENT 'All-time maximum streak',
    `coin_earned_today` INT DEFAULT 0 COMMENT 'Coins earned on this login day',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_user_date (user_id, last_login_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Device Mapping Table
CREATE TABLE IF NOT EXISTS `tbl_device_mapping` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `device_id` VARCHAR(255) UNIQUE NOT NULL,
    `device_type` VARCHAR(20),
    `device_name` VARCHAR(255),
    `first_login` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `last_login` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    `status` ENUM('active', 'suspended') DEFAULT 'active',
    `suspension_reason` VARCHAR(255),
    INDEX idx_user_id (user_id),
    INDEX idx_device (device_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Fraud Detection Table
CREATE TABLE IF NOT EXISTS `tbl_fraud_detection` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `uid` VARCHAR(255),
    `detection_type` ENUM('ad_spam', 'quiz_speed', 'multi_account', 'instant_withdraw', 'unusual_pattern') DEFAULT 'unusual_pattern',
    `reason` VARCHAR(255) NOT NULL,
    `severity` ENUM('low', 'medium', 'high', 'critical') DEFAULT 'low',
    `action_taken` ENUM('none', 'review', 'warning', 'suspend') DEFAULT 'none',
    `action_date` TIMESTAMP NULL,
    `metadata` JSON,
    `resolved` TINYINT DEFAULT 0,
    `resolved_at` TIMESTAMP NULL,
    `resolution_notes` VARCHAR(500),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_severity (severity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sponsor Banners Table
CREATE TABLE IF NOT EXISTS `tbl_sponsor_banners` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `sponsor_name` VARCHAR(255) NOT NULL,
    `title` VARCHAR(255),
    `image_url` VARCHAR(500),
    `image_path` VARCHAR(500),
    `redirect_url` VARCHAR(500),
    `redirect_type` ENUM('url', 'appstore', 'custom') DEFAULT 'url',
    `impression_limit` INT DEFAULT 0,
    `impression_period` ENUM('daily', 'weekly', 'monthly') DEFAULT 'daily',
    `current_impressions` INT DEFAULT 0,
    `impression_reset_date` DATE,
    `start_date` DATETIME NOT NULL,
    `end_date` DATETIME NOT NULL,
    `is_active` TINYINT DEFAULT 1,
    `priority` INT DEFAULT 0,
    `created_by` INT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_active_date (is_active, start_date, end_date),
    INDEX idx_priority (priority)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Banner Impressions Table
CREATE TABLE IF NOT EXISTS `tbl_banner_impressions` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `banner_id` INT NOT NULL,
    `user_id` INT,
    `action` ENUM('showed', 'clicked') DEFAULT 'showed',
    `recorded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_banner_id (banner_id),
    INDEX idx_banner_date (banner_id, recorded_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- STEP 2: Add Monetization Settings
-- ============================================================

-- Daily streak settings
INSERT IGNORE INTO `tbl_settings` (`type`, `message`, `description`) VALUES
('daily_streak_coin_reward', '10', 'Coins awarded for daily login (default: 10)'),
('daily_streak_bonus_threshold', '7', 'Days needed for bonus (0 to disable, default: 7)'),
('daily_streak_bonus_coin', '50', 'Bonus coins at milestone (default: 50)');

-- Boost earnings settings
INSERT IGNORE INTO `tbl_settings` (`type`, `message`, `description`) VALUES
('boost_earnings_coin_multiplier', '2', 'Coin multiplier for boost (default: 2x)'),
('boost_earnings_watch_ad_required', '1', 'Require ad watch for boost (1=yes, 0=no)');

-- Payout eligibility settings
INSERT IGNORE INTO `tbl_settings` (`type`, `message`, `description`) VALUES
('payout_eligibility_days', '20', 'Active days required before payout (default: 20)');

-- Watch unlock settings
INSERT IGNORE INTO `tbl_settings` (`type`, `message`, `description`) VALUES
('watch_unlock_enabled', '1', 'Enable watch ads to unlock (1=yes, 0=no)'),
('watch_unlock_ad_count', '3', 'Ads to watch for unlock (default: 3)');

-- ============================================================
-- STEP 3: Add Test Sponsor Banner Data
-- ============================================================

-- Delete old test banners first
DELETE FROM `tbl_sponsor_banners` WHERE sponsor_name LIKE 'Test%';

-- Insert active test banner
INSERT INTO `tbl_sponsor_banners` 
(`sponsor_name`, `title`, `image_url`, `redirect_url`, `redirect_type`, `start_date`, `end_date`, `is_active`, `priority`) 
VALUES
(
    'Test Sponsor', 
    'Try Our New Quiz App!',
    'https://picsum.photos/800/400',
    'https://google.com',
    'url',
    NOW(),
    DATE_ADD(NOW(), INTERVAL 30 DAY),
    1,
    10
);

-- =====================================================================
-- VERIFICATION QUERIES - Run these to check if everything is set up
-- =====================================================================

-- Check if tables exist
SELECT 
    'tbl_daily_streak' as table_name, 
    COUNT(*) as row_count 
FROM tbl_daily_streak
UNION ALL
SELECT 'tbl_sponsor_banners', COUNT(*) FROM tbl_sponsor_banners
UNION ALL
SELECT 'tbl_device_mapping', COUNT(*) FROM tbl_device_mapping
UNION ALL
SELECT 'tbl_fraud_detection', COUNT(*) FROM tbl_fraud_detection
UNION ALL
SELECT 'tbl_banner_impressions', COUNT(*) FROM tbl_banner_impressions;

-- Check settings
SELECT * FROM tbl_settings 
WHERE type LIKE '%daily_streak%' 
   OR type LIKE '%boost_earnings%'
   OR type LIKE '%payout_%'
   OR type LIKE '%watch_unlock%';

-- Check active banners
SELECT 
    id,
    sponsor_name,
    title,
    image_url,
    redirect_url,
    is_active,
    priority,
    start_date,
    end_date
FROM tbl_sponsor_banners 
WHERE is_active = 1 
  AND NOW() BETWEEN start_date AND end_date
ORDER BY priority DESC;

-- =====================================================================
-- DONE! Now test the app:
-- 1. Build and install the new APK
-- 2. Login to your account
-- 3. Check home screen for:
--    - Daily Streak widget (showing streak count and coins)
--    - Sponsor Banner (showing the test banner image)
-- =====================================================================
