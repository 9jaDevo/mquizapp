-- ============================================================
-- Phase 5C: Partner-Hosted Quiz Competition System
-- Migration: 20260530_create_partner_system.sql
-- Created: 2026-05-30
-- Rollback: see end of file
-- ============================================================

-- 1. Partner organisations
CREATE TABLE IF NOT EXISTS `tbl_partners` (
  `id`                  INT UNSIGNED    NOT NULL AUTO_INCREMENT,
  `firebase_uid`        VARCHAR(128)    NOT NULL,
  `org_name`            VARCHAR(255)    NOT NULL,
  `org_type`            ENUM('church','company','school','individual','ngo','government') NOT NULL DEFAULT 'individual',
  `email`               VARCHAR(191)    NOT NULL,
  `phone`               VARCHAR(32)     NULL,
  `logo_url`            VARCHAR(512)    NULL,
  `website`             VARCHAR(512)    NULL,
  `description`         TEXT            NULL,
  `country`             VARCHAR(3)      NULL,
  `plan`                ENUM('free','starter','pro','enterprise') NOT NULL DEFAULT 'free',
  `plan_expires_at`     DATETIME        NULL,
  `status`              ENUM('pending','active','suspended') NOT NULL DEFAULT 'pending',
  `approved_at`         DATETIME        NULL,
  `approved_by_admin_id` INT            NULL,
  `created_at`          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`          DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_partners_firebase_uid` (`firebase_uid`),
  UNIQUE KEY `uq_partners_email` (`email`),
  KEY `idx_partners_status` (`status`),
  KEY `idx_partners_plan` (`plan`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Partner team members
CREATE TABLE IF NOT EXISTS `tbl_partner_users` (
  `id`            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `partner_id`    INT UNSIGNED  NOT NULL,
  `firebase_uid`  VARCHAR(128)  NOT NULL,
  `email`         VARCHAR(191)  NOT NULL,
  `display_name`  VARCHAR(255)  NOT NULL DEFAULT '',
  `role`          ENUM('owner','admin','manager','viewer') NOT NULL DEFAULT 'viewer',
  `status`        ENUM('active','inactive') NOT NULL DEFAULT 'active',
  `created_at`    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `last_login_at` DATETIME      NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_partner_users_firebase_uid` (`firebase_uid`),
  KEY `idx_partner_users_partner_id` (`partner_id`),
  CONSTRAINT `fk_partner_users_partner_id` FOREIGN KEY (`partner_id`) REFERENCES `tbl_partners` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Partner contests
CREATE TABLE IF NOT EXISTS `tbl_partner_contests` (
  `id`                     INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `partner_id`             INT UNSIGNED  NOT NULL,
  `title`                  VARCHAR(255)  NOT NULL,
  `description`            TEXT          NULL,
  `banner_url`             VARCHAR(512)  NULL,
  `start_date`             DATETIME      NULL,
  `end_date`               DATETIME      NULL,
  `status`                 ENUM('draft','published','live','ended','archived') NOT NULL DEFAULT 'draft',
  `visibility`             ENUM('public','private') NOT NULL DEFAULT 'public',
  `invite_code`            VARCHAR(16)   NULL,
  `entry_type`             ENUM('free','paid') NOT NULL DEFAULT 'free',
  `entry_fee_kobo`         INT           NOT NULL DEFAULT 0,
  `max_participants`       INT           NOT NULL DEFAULT 50,
  `time_limit_seconds`     INT           NOT NULL DEFAULT 20,
  `question_count`         INT           NOT NULL DEFAULT 0,
  `prize_description`      TEXT          NULL,
  `coin_prize_pool`        INT           NOT NULL DEFAULT 0,
  `allow_retakes`          TINYINT(1)    NOT NULL DEFAULT 0,
  `custom_join_message`    TEXT          NULL,
  `custom_complete_message` TEXT         NULL,
  `prize_distributed`      TINYINT(1)    NOT NULL DEFAULT 0,
  `created_at`             DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at`             DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_partner_contests_invite_code` (`invite_code`),
  KEY `idx_partner_contests_partner_id` (`partner_id`),
  KEY `idx_partner_contests_visibility_status` (`visibility`, `status`),
  KEY `idx_partner_contests_status` (`status`),
  CONSTRAINT `fk_partner_contests_partner_id` FOREIGN KEY (`partner_id`) REFERENCES `tbl_partners` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Partner contest questions (custom or copied from mQuiz bank)
CREATE TABLE IF NOT EXISTS `tbl_partner_contest_questions` (
  `id`               INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `contest_id`       INT UNSIGNED  NOT NULL,
  `question_order`   INT           NOT NULL DEFAULT 0,
  `question_text`    TEXT          NOT NULL,
  `image_url`        VARCHAR(512)  NULL,
  `option_a`         TEXT          NOT NULL,
  `option_b`         TEXT          NOT NULL,
  `option_c`         TEXT          NOT NULL,
  `option_d`         TEXT          NOT NULL,
  `option_e`         TEXT          NULL,
  `answer`           VARCHAR(1)    NOT NULL,
  `explanation`      TEXT          NULL,
  `question_type`    ENUM('mcq','true_false') NOT NULL DEFAULT 'mcq',
  `source`           ENUM('custom','bank') NOT NULL DEFAULT 'custom',
  `bank_question_id` INT           NULL,
  `created_at`       DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_pcq_contest_id` (`contest_id`),
  KEY `idx_pcq_order` (`contest_id`, `question_order`),
  CONSTRAINT `fk_pcq_contest_id` FOREIGN KEY (`contest_id`) REFERENCES `tbl_partner_contests` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Partner contest participants
CREATE TABLE IF NOT EXISTS `tbl_partner_contest_participants` (
  `id`            INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `contest_id`    INT UNSIGNED  NOT NULL,
  `user_id`       INT UNSIGNED  NOT NULL,
  `joined_at`     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `has_submitted` TINYINT(1)    NOT NULL DEFAULT 0,
  `submitted_at`  DATETIME      NULL,
  `score`         FLOAT         NOT NULL DEFAULT 0,
  `correct_count` INT           NOT NULL DEFAULT 0,
  `time_taken_ms` INT           NOT NULL DEFAULT 0,
  `rank`          INT           NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_pcp_contest_user` (`contest_id`, `user_id`),
  KEY `idx_pcp_contest_id` (`contest_id`),
  KEY `idx_pcp_user_id` (`user_id`),
  CONSTRAINT `fk_pcp_contest_id` FOREIGN KEY (`contest_id`) REFERENCES `tbl_partner_contests` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Partner contest leaderboard (pre-computed, updated on each submit)
CREATE TABLE IF NOT EXISTS `tbl_partner_contest_leaderboard` (
  `id`              INT UNSIGNED  NOT NULL AUTO_INCREMENT,
  `contest_id`      INT UNSIGNED  NOT NULL,
  `user_id`         INT UNSIGNED  NOT NULL,
  `display_name`    VARCHAR(255)  NOT NULL DEFAULT '',
  `avatar_url`      VARCHAR(512)  NULL,
  `score`           FLOAT         NOT NULL DEFAULT 0,
  `correct_answers` INT           NOT NULL DEFAULT 0,
  `time_taken_ms`   INT           NOT NULL DEFAULT 0,
  `rank`            INT           NOT NULL DEFAULT 0,
  `last_updated`    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_pcl_contest_user` (`contest_id`, `user_id`),
  KEY `idx_pcl_contest_id` (`contest_id`),
  KEY `idx_pcl_score` (`contest_id`, `score` DESC),
  CONSTRAINT `fk_pcl_contest_id` FOREIGN KEY (`contest_id`) REFERENCES `tbl_partner_contests` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- ROLLBACK (run in reverse order):
-- DROP TABLE IF EXISTS `tbl_partner_contest_leaderboard`;
-- DROP TABLE IF EXISTS `tbl_partner_contest_participants`;
-- DROP TABLE IF EXISTS `tbl_partner_contest_questions`;
-- DROP TABLE IF EXISTS `tbl_partner_contests`;
-- DROP TABLE IF EXISTS `tbl_partner_users`;
-- DROP TABLE IF EXISTS `tbl_partners`;
-- ============================================================
