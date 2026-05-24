-- =============================================================================
-- mQuiz Phase 1 — New tables for Lives, Boosters, Progress
-- Notifications reuse existing tbl_notifications.
-- Payments reuse existing tbl_payment_request.
-- Idempotent: safe to run multiple times.
-- =============================================================================

CREATE TABLE IF NOT EXISTS `tbl_user_lives` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `current` INT NOT NULL DEFAULT 5,
  `max` INT NOT NULL DEFAULT 5,
  `last_refill_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_lives_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `tbl_booster_type` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(64) NOT NULL,
  `name` VARCHAR(128) NOT NULL,
  `description` TEXT NULL,
  `cost_coins` INT NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_booster_type_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `tbl_user_booster_inventory` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `booster_type_id` INT NOT NULL,
  `quantity` INT NOT NULL DEFAULT 0,
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_booster` (`user_id`, `booster_type_id`),
  KEY `idx_ubi_user` (`user_id`),
  KEY `idx_ubi_booster_type` (`booster_type_id`),
  CONSTRAINT `fk_ubi_booster_type` FOREIGN KEY (`booster_type_id`) REFERENCES `tbl_booster_type`(`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `tbl_progress_stage` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `stage_number` INT NOT NULL,
  `name` VARCHAR(128) NOT NULL,
  `min_score` INT NOT NULL DEFAULT 0,
  `icon_url` VARCHAR(500) NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_progress_stage_number` (`stage_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

CREATE TABLE IF NOT EXISTS `tbl_user_progress` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `user_id` INT NOT NULL,
  `stage_number` INT NOT NULL DEFAULT 1,
  `total_score` INT NOT NULL DEFAULT 0,
  `updated_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_progress_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- Seed initial booster types (idempotent via code unique key)
INSERT IGNORE INTO `tbl_booster_type` (`code`, `name`, `description`, `cost_coins`, `is_active`) VALUES
  ('FIFTY_FIFTY', '50:50', 'Removes two wrong options', 50, 1),
  ('SKIP', 'Skip Question', 'Skip the current question with no penalty', 30, 1),
  ('EXTRA_TIME', 'Extra Time', 'Add 15 seconds to the timer', 25, 1),
  ('HINT', 'Hint', 'Show a hint about the correct answer', 40, 1);

-- Seed initial progress stages
INSERT IGNORE INTO `tbl_progress_stage` (`stage_number`, `name`, `min_score`, `is_active`) VALUES
  (1, 'Rookie', 0, 1),
  (2, 'Apprentice', 500, 1),
  (3, 'Scholar', 2000, 1),
  (4, 'Expert', 5000, 1),
  (5, 'Master', 12000, 1),
  (6, 'Grandmaster', 25000, 1);
