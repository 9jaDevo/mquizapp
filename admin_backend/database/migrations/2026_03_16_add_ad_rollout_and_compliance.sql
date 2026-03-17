-- ================================================================
-- Ad Rollout + Compliance Upload Backend Support
-- ================================================================

-- 1) Store compliance/audit events uploaded from the app
CREATE TABLE IF NOT EXISTS `tbl_ad_compliance_events` (
  `id` BIGINT(20) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` INT(11) NOT NULL,
  `firebase_id` VARCHAR(255) DEFAULT NULL,
  `event_name` VARCHAR(100) NOT NULL,
  `event_ts` DATETIME DEFAULT NULL,
  `event_payload` LONGTEXT DEFAULT NULL,
  `platform` VARCHAR(20) DEFAULT NULL,
  `app_version` VARCHAR(20) DEFAULT NULL,
  `ip_address` VARCHAR(45) DEFAULT NULL,
  `created_at` DATETIME NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_ad_compliance_user_id` (`user_id`),
  KEY `idx_ad_compliance_event_name` (`event_name`),
  KEY `idx_ad_compliance_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2) Add rollout and compliance settings consumed by app/backend
INSERT INTO `tbl_settings` (`type`, `message`) VALUES
('ad_rollout_utility_interstitials', '1'),
('ad_rollout_wallet_banner_placement', '1'),
('ad_rollout_coin_store_banner_placement', '1'),
('ad_rollout_rewarded_fallback', '1'),
('ad_compliance_upload_enabled', '1'),
('ad_compliance_upload_batch_size', '25')
ON DUPLICATE KEY UPDATE `message` = VALUES(`message`);
