-- Migration: 2026_05_25_add_user_bookmarks_table
-- Creates tbl_user_bookmarks for the Flutter bookmark feature.
-- Users can save quiz questions to revisit later.
-- Unique constraint prevents duplicate bookmarks per user.
-- Rollback section at bottom.

-- ── UP ────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS `tbl_user_bookmarks` (
  `id`          INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  `user_id`     INT UNSIGNED    NOT NULL  COMMENT 'FK → tbl_users.id',
  `question_id` INT             NOT NULL  COMMENT 'FK → tbl_questions.id',
  `created_at`  DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_user_question` (`user_id`, `question_id`),
  KEY `idx_bookmarks_user_id` (`user_id`),
  KEY `idx_bookmarks_question_id` (`question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  COMMENT='Stores question bookmarks saved by each user';

-- ── DOWN (rollback) ────────────────────────────────────────────────────────
-- DROP TABLE IF EXISTS `tbl_user_bookmarks`;
