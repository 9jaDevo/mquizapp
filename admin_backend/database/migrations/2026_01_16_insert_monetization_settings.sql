-- =================================================================
-- Insert New Settings for Monetization Features
-- Note: Using 'type' and 'message' columns as per existing schema
-- =================================================================

INSERT INTO `tbl_settings` (`type`, `message`) VALUES

-- ============================================================
-- Daily Streak Configuration
-- ============================================================
('daily_streak_coin_reward', '10'),
('daily_streak_multiplier_enable', '1'),
('daily_streak_bonus_threshold', '7'),
('daily_streak_bonus_coin', '50'),

-- ============================================================
-- Payout Eligibility Requirements
-- ============================================================
('min_active_days_for_payout', '20'),
('activity_tracking_window_days', '30'),

-- ============================================================
-- Device Verification & Multi-Account Prevention
-- ============================================================
('device_one_account_enforcement', '1'),
('device_suspension_action', 'suspend'),

-- ============================================================
-- Fraud Detection Thresholds
-- ============================================================
('fraud_daily_ad_limit', '100'),
('fraud_quiz_accuracy_threshold', '95'),
('fraud_quiz_speed_seconds', '10'),
('fraud_new_account_withdrawal_days', '7'),
('fraud_auto_review_threshold', 'high'),

-- ============================================================
-- Boost Earnings Feature
-- ============================================================
('boost_earnings_coin_multiplier', '2'),
('boost_earnings_watch_ad_required', '1'),

-- ============================================================
-- Watch & Unlock Premium Content via Ads
-- ============================================================
('watch_unlock_ad_count', '3'),
('watch_unlock_enable', '1'),

-- ============================================================
-- Sponsor Banner Configuration
-- ============================================================
('sponsor_banner_enable', '1'),
('sponsor_banner_rotation_seconds', '5'),
('sponsor_banner_analytics_track_user', '1'),

-- ============================================================
-- Anti-Referral Farming System (Enhanced/Bonus Rewards)
-- Note: These are BONUS rewards given after activity requirements are met
--       Your existing refer_coin/earn_coin provide instant rewards
--       This tiered approach: instant small reward + delayed large bonus
-- ============================================================

-- Activity Requirements (must meet these to get bonus)
('referral_reward_min_active_days', '7'),
('referral_reward_min_quizzes', '10'),

-- Bonus Rewards (given AFTER 7 days + 10 quizzes)
-- Recommendation: Set existing refer_coin=20, earn_coin=50 for instant rewards
-- Then these bonuses (+30, +50) make total rewards: 50 + 100 coins
('referral_bonus_referrer_coins', '30'),
('referral_bonus_referee_coins', '50'),

-- Fraud Prevention Settings
('referral_max_per_day', '5'),
('referral_max_per_device', '3'),
('referral_verify_device_unique', '1'),
('referral_verify_email_unique', '1'),
('referral_block_same_ip', '1'),
('referral_same_ip_max_count', '2'),

-- Enable Tiered Referral System (0=disabled, 1=enabled)
('referral_bonus_system_enable', '1');

-- =================================================================
-- END OF SETTINGS INSERT
-- Note: All settings are now configurable via admin panel
-- No hardcoded values in code
-- =================================================================
