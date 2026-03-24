-- Migration: Phase 4 - Regional Frequency Limit Overrides (v2.4.4)
-- Purpose: Allow admins to override default ad frequency limits per region
-- Date: 2026-03-24

-- Add regional frequency limit settings (non-EU regions only for now)
-- These allow admins to boost or reduce frequency caps dynamically

INSERT INTO `tbl_settings` (`type`, `message`) VALUES 
('ad_frequency_interstitial_other_min_gap_ms', '30000'), -- 30 seconds (down from 60s)
('ad_frequency_interstitial_other_max_per_day', '12'), -- Up from 5
('ad_frequency_rewarded_other_min_gap_ms', '45000'), -- 45 seconds (down from 60s)
('ad_frequency_rewarded_other_max_per_day', '20') -- Up from 10
AS new_values
ON DUPLICATE KEY UPDATE `message` = new_values.`message`;

-- Note: To override these values, admins can:
-- 1. Use Settings.php /ads_settings form (if fields added)
-- 2. Direct database update: UPDATE tbl_settings SET value='15000' WHERE type='ad_frequency_interstitial_other_min_gap_ms'
-- 3. API call: POST /api/update_setting with type + value

-- These settings are currently hardcoded in geographic_segmentation.dart
-- Future enhancement: Load these from backend via get_system_configurations API
