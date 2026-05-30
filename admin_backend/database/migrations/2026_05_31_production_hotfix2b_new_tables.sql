-- =============================================================================
-- Production Hotfix #2b — 2026-05-31
-- Creates missing tables and seeds initial data
-- Run with: --force to skip already-applied changes
-- =============================================================================

-- ── 1. Fix leagues with past end_date — extend by 90 days ────────────────────
UPDATE `tbl_league`
SET `end_date` = DATE_ADD(NOW(), INTERVAL 90 DAY)
WHERE `end_date` < NOW();

UPDATE `tbl_league`
SET `status` = 1
WHERE `status` != 1;

-- ── 2. Fix contests with past end_date — extend by 90 days ───────────────────
UPDATE `tbl_contest`
SET `end_date` = DATE_ADD(NOW(), INTERVAL 90 DAY)
WHERE `end_date` < NOW();

UPDATE `tbl_contest`
SET `status` = 1
WHERE `status` != 1;

-- ── 3. Create tbl_booster_type ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `tbl_booster_type` (
  `id`          INT NOT NULL AUTO_INCREMENT,
  `code`        VARCHAR(64) NOT NULL,
  `name`        VARCHAR(128) NOT NULL,
  `description` TEXT NULL,
  `cost_coins`  INT NOT NULL DEFAULT 0,
  `is_active`   TINYINT(1) NOT NULL DEFAULT 1,
  `created_at`  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_booster_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── 4. Create tbl_user_booster_inventory ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS `tbl_user_booster_inventory` (
  `id`              INT NOT NULL AUTO_INCREMENT,
  `user_id`         INT NOT NULL,
  `booster_type_id` INT NOT NULL,
  `quantity`        INT NOT NULL DEFAULT 0,
  `updated_at`      DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_booster` (`user_id`, `booster_type_id`),
  KEY `idx_ubi_user` (`user_id`),
  CONSTRAINT `fk_ubi_booster_type` FOREIGN KEY (`booster_type_id`) REFERENCES `tbl_booster_type` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── 5. Create tbl_progress_stage ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `tbl_progress_stage` (
  `id`           INT NOT NULL AUTO_INCREMENT,
  `stage_number` INT NOT NULL,
  `name`         VARCHAR(128) NOT NULL,
  `min_score`    INT NOT NULL DEFAULT 0,
  `icon_url`     VARCHAR(500) NULL,
  `is_active`    TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_stage_number` (`stage_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── 6. Create tbl_user_progress ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `tbl_user_progress` (
  `id`           INT NOT NULL AUTO_INCREMENT,
  `user_id`      INT NOT NULL,
  `stage_number` INT NOT NULL DEFAULT 1,
  `total_score`  INT NOT NULL DEFAULT 0,
  `updated_at`   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_progress` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ── 7. Seed booster types ─────────────────────────────────────────────────────
INSERT IGNORE INTO `tbl_booster_type` (`code`, `name`, `description`, `cost_coins`, `is_active`)
VALUES
  ('50_50',       '50/50 Lifeline', 'Removes two wrong answer options', 30, 1),
  ('time_freeze', 'Time Freeze',    'Freezes the timer for 30 seconds', 30, 1),
  ('skip',        'Skip Question',  'Skips the current question without penalty', 20, 1),
  ('double_coins','Double Coins',   'Doubles coins earned for correct answers', 50, 1);

-- ── 8. Seed progress stages ───────────────────────────────────────────────────
INSERT IGNORE INTO `tbl_progress_stage` (`stage_number`, `name`, `min_score`, `is_active`)
VALUES
  (1,  'Rookie',       0,     1),
  (2,  'Apprentice',   500,   1),
  (3,  'Scholar',      1500,  1),
  (4,  'Expert',       3500,  1),
  (5,  'Master',       7000,  1),
  (6,  'Champion',     12000, 1),
  (7,  'Grandmaster',  20000, 1),
  (8,  'Legend',       35000, 1);
