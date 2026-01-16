-- =================================================================
-- PHASE 1: Monetization & Engagement Features - Database Migration
-- Date: 2026-01-16
-- Purpose: Add tables for daily streak, device tracking, fraud detection, and sponsor banners
-- =================================================================

-- ============================================================
-- Table 1: tbl_daily_streak
-- Purpose: Track user daily login streaks and earn coins
-- ============================================================
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
    INDEX idx_user_date (user_id, last_login_date),
    INDEX idx_updated (updated_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table 2: tbl_device_mapping
-- Purpose: Prevent multi-accounting - one account per device
-- ============================================================
CREATE TABLE IF NOT EXISTS `tbl_device_mapping` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `device_id` VARCHAR(255) UNIQUE NOT NULL COMMENT 'Firebase Device ID or unique device fingerprint',
    `device_type` VARCHAR(20) COMMENT 'android or ios',
    `device_name` VARCHAR(255),
    `first_login` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `last_login` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    `status` ENUM('active', 'suspended') DEFAULT 'active',
    `suspension_reason` VARCHAR(255),
    
    INDEX idx_user_id (user_id),
    INDEX idx_device (device_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table 3: tbl_fraud_detection
-- Purpose: Track and manage suspicious user activities
-- ============================================================
CREATE TABLE IF NOT EXISTS `tbl_fraud_detection` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `uid` VARCHAR(255),
    `detection_type` ENUM(
        'ad_spam',
        'quiz_speed',
        'multi_account',
        'instant_withdraw',
        'unusual_pattern'
    ) DEFAULT 'unusual_pattern',
    `reason` VARCHAR(255) NOT NULL,
    `severity` ENUM('low', 'medium', 'high', 'critical') DEFAULT 'low',
    `action_taken` ENUM('none', 'review', 'warning', 'suspend') DEFAULT 'none',
    `action_date` TIMESTAMP NULL,
    `metadata` JSON COMMENT 'Additional detection data (e.g., ad count, accuracy %)',
    `resolved` TINYINT DEFAULT 0,
    `resolved_at` TIMESTAMP NULL,
    `resolution_notes` VARCHAR(500),
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_user_id (user_id),
    INDEX idx_user_type (user_id, detection_type),
    INDEX idx_severity (severity),
    INDEX idx_resolved (resolved)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table 4: tbl_sponsor_banners
-- Purpose: Manage rotating sponsor advertisements
-- ============================================================
CREATE TABLE IF NOT EXISTS `tbl_sponsor_banners` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `sponsor_name` VARCHAR(255) NOT NULL,
    `title` VARCHAR(255),
    `image_url` VARCHAR(500),
    `image_path` VARCHAR(500) COMMENT 'Local storage path',
    `redirect_url` VARCHAR(500) COMMENT 'URL opened on banner click',
    `redirect_type` ENUM('url', 'appstore', 'custom') DEFAULT 'url',
    
    -- Impression tracking
    `impression_limit` INT DEFAULT 0 COMMENT '0 = unlimited impressions',
    `impression_period` ENUM('daily', 'weekly', 'monthly') DEFAULT 'daily',
    `current_impressions` INT DEFAULT 0,
    `impression_reset_date` DATE,
    
    -- Date range
    `start_date` DATETIME NOT NULL,
    `end_date` DATETIME NOT NULL,
    
    -- Status
    `is_active` TINYINT DEFAULT 1,
    `priority` INT DEFAULT 0 COMMENT 'Higher priority shown first',
    
    -- Tracking
    `created_by` INT,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_created_by (created_by),
    INDEX idx_active_date (is_active, start_date, end_date),
    INDEX idx_priority (priority)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table 5: tbl_banner_impressions
-- Purpose: Track sponsor banner views and clicks for analytics
-- ============================================================
CREATE TABLE IF NOT EXISTS `tbl_banner_impressions` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `banner_id` INT NOT NULL,
    `user_id` INT COMMENT 'NULL for anonymous tracking',
    `action` ENUM('showed', 'clicked') DEFAULT 'showed',
    `recorded_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_banner_id (banner_id),
    INDEX idx_banner_date (banner_id, recorded_at),
    INDEX idx_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =================================================================
-- END OF MIGRATION
-- =================================================================
