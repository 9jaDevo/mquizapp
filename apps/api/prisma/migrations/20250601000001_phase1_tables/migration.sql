-- =============================================================================
-- Phase 1 NestJS Tables — Production Database Migration
-- Database: mquiz_newportal (MySQL 8)
-- Safe to run multiple times: CREATE TABLE uses IF NOT EXISTS
-- For ALTER TABLE: check column existence first (see inline comment)
-- =============================================================================

-- ----------------------------------------------------------------
-- 1. Add `status` column to tbl_category
--    (MySQL does not support ADD COLUMN IF NOT EXISTS natively)
--    Run the check first:
--      SELECT COLUMN_NAME FROM information_schema.COLUMNS
--        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'tbl_category'
--        AND COLUMN_NAME = 'status';
--    Only run the ALTER if the query above returns 0 rows.
-- ----------------------------------------------------------------
ALTER TABLE `tbl_category`
  ADD COLUMN `status` TINYINT NOT NULL DEFAULT 1 AFTER `coins`;

-- Update all existing rows to active (status=1)
UPDATE `tbl_category` SET `status` = 1;

-- Add index for the new column
ALTER TABLE `tbl_category`
  ADD INDEX `idx_category_status` (`status`);

-- ----------------------------------------------------------------
-- 2. Create tbl_user_lives (Phase 1 — NestJS lives system)
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `tbl_user_lives` (
  `id`             INT         NOT NULL AUTO_INCREMENT,
  `user_id`        INT         NOT NULL,
  `current`        INT         NOT NULL DEFAULT 5,
  `max`            INT         NOT NULL DEFAULT 5,
  `last_refill_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at`     DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
                               ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `tbl_user_lives_user_id_key` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------
-- 3. Create tbl_progress_stage (Phase 1 — NestJS stage definitions)
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `tbl_progress_stage` (
  `id`           INT          NOT NULL AUTO_INCREMENT,
  `stage_number` INT          NOT NULL,
  `name`         VARCHAR(128) NOT NULL,
  `min_score`    INT          NOT NULL DEFAULT 0,
  `icon_url`     VARCHAR(500) NULL,
  `is_active`    TINYINT(1)   NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `tbl_progress_stage_stage_number_key` (`stage_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------
-- 4. Create tbl_user_progress (Phase 1 — per-user stage progress)
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `tbl_user_progress` (
  `id`           INT         NOT NULL AUTO_INCREMENT,
  `user_id`      INT         NOT NULL,
  `stage_number` INT         NOT NULL DEFAULT 1,
  `total_score`  INT         NOT NULL DEFAULT 0,
  `updated_at`   DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
                             ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `tbl_user_progress_user_id_key` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------
-- 5. Create tbl_booster_type (Phase 1 — booster definitions)
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `tbl_booster_type` (
  `id`          INT          NOT NULL AUTO_INCREMENT,
  `code`        VARCHAR(64)  NOT NULL,
  `name`        VARCHAR(128) NOT NULL,
  `description` TEXT         NULL,
  `cost_coins`  INT          NOT NULL DEFAULT 0,
  `is_active`   TINYINT(1)   NOT NULL DEFAULT 1,
  `created_at`  DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `tbl_booster_type_code_key` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------
-- 6. Create tbl_user_booster_inventory (Phase 1 — user booster stock)
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `tbl_user_booster_inventory` (
  `id`              INT         NOT NULL AUTO_INCREMENT,
  `user_id`         INT         NOT NULL,
  `booster_type_id` INT         NOT NULL,
  `quantity`        INT         NOT NULL DEFAULT 0,
  `updated_at`      DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3)
                                ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uniq_user_booster`      (`user_id`, `booster_type_id`),
  KEY           `idx_ubi_user`        (`user_id`),
  CONSTRAINT `tbl_user_booster_inventory_booster_type_id_fkey`
    FOREIGN KEY (`booster_type_id`) REFERENCES `tbl_booster_type` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------
-- 7. Create tbl_user_bookmarks (Phase 1 — NestJS bookmark feature)
--    Note: the PHP app uses `tbl_bookmark` (singular) — this is a
--    separate NestJS-managed table.
-- ----------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `tbl_user_bookmarks` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED NOT NULL,
  `question_id` INT          NOT NULL,
  `created_at`  DATETIME(3)  NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_question`       (`user_id`, `question_id`),
  KEY           `idx_bookmarks_user_id`     (`user_id`),
  KEY           `idx_bookmarks_question_id` (`question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ----------------------------------------------------------------
-- 8. Seed tbl_progress_stage with default stages (INSERT IGNORE is
--    idempotent — skips rows whose stage_number already exists)
-- ----------------------------------------------------------------
INSERT IGNORE INTO `tbl_progress_stage`
  (`stage_number`, `name`, `min_score`, `is_active`)
VALUES
  (1, 'Novice',       0,     1),
  (2, 'Beginner',     500,   1),
  (3, 'Intermediate', 1500,  1),
  (4, 'Advanced',     3000,  1),
  (5, 'Expert',       6000,  1),
  (6, 'Master',       10000, 1),
  (7, 'Grandmaster',  15000, 1),
  (8, 'Legend',       25000, 1);
