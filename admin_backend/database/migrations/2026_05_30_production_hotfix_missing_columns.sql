-- ============================================================
-- Production Hotfix: Apply all migrations missing from mquiz_newportal
-- Run with --force so "duplicate column" (1060) / "duplicate key" (1061)
-- errors for already-applied statements are skipped automatically.
-- ============================================================

-- 1. tbl_users.age_group  (2026_05_29_add_age_group_to_tbl_users)
ALTER TABLE `tbl_users`
  ADD COLUMN `age_group` VARCHAR(20) NULL DEFAULT NULL
  COMMENT 'child | teen | adult | senior';

-- 2. tbl_category.status  (2026_05_25_add_status_to_category)
ALTER TABLE `tbl_category`
  ADD COLUMN `status` TINYINT NOT NULL DEFAULT 1
  COMMENT '1 = active, 0 = inactive'
  AFTER `row_order`;
CREATE INDEX IF NOT EXISTS `idx_category_status` ON `tbl_category` (`status`);

-- 3. tbl_question.ai_generated  (2026_05_29_add_ai_generated_to_tbl_question)
ALTER TABLE `tbl_question`
  ADD COLUMN `ai_generated` TINYINT(1) NOT NULL DEFAULT 0
  COMMENT '0 = manual, 1 = AI-approved'
  AFTER `note`;
CREATE INDEX IF NOT EXISTS `idx_question_ai_generated` ON `tbl_question` (`ai_generated`);

-- 4. tbl_notifications delivery counts  (2026_05_29_add_delivery_counts_to_tbl_notifications)
ALTER TABLE `tbl_notifications`
  ADD COLUMN `delivered_count` INT NOT NULL DEFAULT 0 AFTER `date_sent`;
ALTER TABLE `tbl_notifications`
  ADD COLUMN `failed_count` INT NOT NULL DEFAULT 0 AFTER `delivered_count`;

-- 5. tbl_user_bookmarks  (2026_05_25_add_user_bookmarks_table)
CREATE TABLE IF NOT EXISTS `tbl_user_bookmarks` (
  `id`          INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED NOT NULL  COMMENT 'FK tbl_users.id',
  `question_id` INT          NOT NULL  COMMENT 'FK tbl_questions.id',
  `created_at`  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_question` (`user_id`, `question_id`),
  KEY `idx_bookmarks_user_id` (`user_id`),
  KEY `idx_bookmarks_question_id` (`question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Stores question bookmarks saved by each user';

-- 6. tbl_scheduled_notifications  (2026_05_29_create_tbl_scheduled_notifications)
CREATE TABLE IF NOT EXISTS `tbl_scheduled_notifications` (
  `id`         INT          NOT NULL AUTO_INCREMENT,
  `title`      VARCHAR(128) NOT NULL,
  `message`    TEXT         NOT NULL,
  `user_ids`   LONGTEXT     NULL    COMMENT 'NULL = broadcast to all',
  `type`       VARCHAR(50)  NOT NULL DEFAULT 'general',
  `type_id`    INT          NOT NULL DEFAULT 0,
  `image`      VARCHAR(128) NOT NULL DEFAULT '',
  `send_at`    DATETIME     NOT NULL,
  `created_at` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_sched_notif_send_at` (`send_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SELECT 'Hotfix complete.' AS result;
