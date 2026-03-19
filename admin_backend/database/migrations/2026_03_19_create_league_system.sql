-- ========================================================
-- League System Database Schema
-- ========================================================
-- Created: 2026-03-19
-- Purpose: league opt-in, daily play, leaderboard, notifications, and prizes
-- ========================================================

-- ========================================================
-- Table: tbl_league
-- ========================================================
CREATE TABLE IF NOT EXISTS `tbl_league` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `language_id` INT NOT NULL DEFAULT 0,
  `name` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `description` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `start_date` DATETIME NOT NULL,
  `end_date` DATETIME NOT NULL,
  `entry` INT NOT NULL DEFAULT 0 COMMENT 'entry coins',
  `created_by` INT NOT NULL DEFAULT 0,
  `prize_status` INT NOT NULL DEFAULT 0 COMMENT '0=not distributed,1=distributed',
  `status` INT NOT NULL DEFAULT 1 COMMENT '0=deactive,1=active',
  `date_created` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `date_updated` DATETIME NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_league_status` (`status`),
  KEY `idx_league_dates` (`start_date`,`end_date`),
  KEY `idx_league_language` (`language_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ========================================================
-- Table: tbl_league_user
-- ========================================================
CREATE TABLE IF NOT EXISTS `tbl_league_user` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `league_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `status` VARCHAR(20) NOT NULL DEFAULT 'opt-in' COMMENT 'opt-in,active,withdrawn',
  `opted_in_at` DATETIME NULL DEFAULT NULL,
  `joined_at` DATETIME NULL DEFAULT NULL,
  `coins_paid` INT NOT NULL DEFAULT 0,
  `device_token` VARCHAR(512) NULL DEFAULT NULL,
  `notifications_enabled` TINYINT NOT NULL DEFAULT 1,
  `date_created` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_league_user` (`league_id`,`user_id`),
  KEY `idx_league_user_status` (`status`),
  KEY `idx_league_user_user` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ========================================================
-- Table: tbl_league_daily_quiz
-- ========================================================
CREATE TABLE IF NOT EXISTS `tbl_league_daily_quiz` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `league_id` INT NOT NULL,
  `quiz_day` INT NOT NULL COMMENT '1..N day in league',
  `quiz_date` DATE NOT NULL,
  `question_count` INT NOT NULL DEFAULT 20,
  `date_assigned` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_league_day` (`league_id`,`quiz_day`),
  KEY `idx_league_quiz_date` (`quiz_date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ========================================================
-- Table: tbl_league_daily_quiz_questions
-- ========================================================
CREATE TABLE IF NOT EXISTS `tbl_league_daily_quiz_questions` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `daily_quiz_id` INT NOT NULL,
  `question_id` INT NOT NULL,
  `question_order` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_daily_quiz_question` (`daily_quiz_id`,`question_id`),
  KEY `idx_daily_quiz_order` (`daily_quiz_id`,`question_order`),
  KEY `idx_daily_question` (`question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ========================================================
-- Table: tbl_league_submission
-- ========================================================
CREATE TABLE IF NOT EXISTS `tbl_league_submission` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `league_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `daily_quiz_id` INT NOT NULL,
  `quiz_day` INT NOT NULL,
  `score` DOUBLE NOT NULL DEFAULT 0,
  `correct_answers` INT NOT NULL DEFAULT 0,
  `wrong_answers` INT NOT NULL DEFAULT 0,
  `total_questions` INT NOT NULL DEFAULT 0,
  `ad_shown` TINYINT NOT NULL DEFAULT 0,
  `submission_date` DATE NOT NULL,
  `submitted_at` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `date_created` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_submission_league_user_day` (`league_id`,`user_id`,`quiz_day`),
  KEY `idx_submission_daily_quiz` (`daily_quiz_id`),
  KEY `idx_submission_date` (`submission_date`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ========================================================
-- Table: tbl_league_leaderboard
-- ========================================================
CREATE TABLE IF NOT EXISTS `tbl_league_leaderboard` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `league_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `cumulative_best_score` DOUBLE NOT NULL DEFAULT 0,
  `daily_best_scores` JSON NULL,
  `games_played` INT NOT NULL DEFAULT 0,
  `rank` INT NULL DEFAULT NULL,
  `last_updated` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `date_created` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_league_leaderboard_user` (`league_id`,`user_id`),
  KEY `idx_leaderboard_rank_sort` (`league_id`,`cumulative_best_score`,`last_updated`),
  KEY `idx_leaderboard_rank` (`rank`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ========================================================
-- Table: tbl_league_notification_log
-- ========================================================
CREATE TABLE IF NOT EXISTS `tbl_league_notification_log` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `league_id` INT NOT NULL,
  `user_id` INT NOT NULL,
  `notification_type` VARCHAR(50) NOT NULL COMMENT 'pre-league,start-day',
  `status` VARCHAR(20) NOT NULL DEFAULT 'sent' COMMENT 'sent,failed,skipped',
  `sent_at` DATETIME NULL DEFAULT NULL,
  `device_token` VARCHAR(512) NULL DEFAULT NULL,
  `error_message` TEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin,
  `date_created` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notif_lookup` (`league_id`,`user_id`,`notification_type`),
  KEY `idx_notif_status` (`status`),
  KEY `idx_notif_sent` (`sent_at`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- ========================================================
-- Table: tbl_league_prize
-- ========================================================
CREATE TABLE IF NOT EXISTS `tbl_league_prize` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `league_id` INT NOT NULL,
  `top_winner` INT NOT NULL COMMENT '1,2,3',
  `points` INT NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_league_prize_rank` (`league_id`,`top_winner`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
