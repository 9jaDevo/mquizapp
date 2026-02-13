-- Migration for Hybrid Positioning System: Student/Professional Paths
-- Created: 2026-02-13
-- Description: Creates tables and modifies existing schema for path-based personalization

-- ==================================================
-- 1. Create user_paths table
-- ==================================================
CREATE TABLE IF NOT EXISTS `tbl_user_paths` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `selected_path` enum('student','professional','competition') NOT NULL DEFAULT 'student',
  `can_switch` tinyint(1) NOT NULL DEFAULT 1,
  `selected_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `topics_preference` text DEFAULT NULL COMMENT 'JSON array of preferred topics',
  `daily_goal_minutes` int NOT NULL DEFAULT 10 COMMENT 'Daily learning goal: 5, 10, or 20 minutes',
  `onboarding_completed` tinyint(1) NOT NULL DEFAULT 0,
  `demo_quiz_completed` tinyint(1) NOT NULL DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `selected_path` (`selected_path`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==================================================
-- 2. Alter categories table - add target audience and content type
-- ==================================================
ALTER TABLE `tbl_category` 
ADD COLUMN IF NOT EXISTS `target_audience` enum('student','professional','both','general') NOT NULL DEFAULT 'general' AFTER `is_premium`,
ADD COLUMN IF NOT EXISTS `content_type` enum('academic','workplace','skill','general') NOT NULL DEFAULT 'general' AFTER `target_audience`,
ADD KEY `target_audience` (`target_audience`),
ADD KEY `content_type` (`content_type`);

-- ==================================================
-- 3. Alter questions table - add enhanced fields
-- ==================================================
ALTER TABLE `tbl_question`
MODIFY COLUMN `question_type` tinyint NOT NULL DEFAULT 1 COMMENT '1=MCQ, 2=true/false, 3=scenario, 4=case_study',
ADD COLUMN IF NOT EXISTS `context` text DEFAULT NULL COMMENT 'Scenario/case study context' AFTER `note`,
ADD COLUMN IF NOT EXISTS `difficulty_level` enum('beginner','intermediate','advanced') NOT NULL DEFAULT 'beginner' AFTER `context`,
ADD COLUMN IF NOT EXISTS `skill_tags` text DEFAULT NULL COMMENT 'JSON array of skills: ["leadership", "problem-solving"]' AFTER `difficulty_level`,
ADD KEY `difficulty_level` (`difficulty_level`);

-- ==================================================
-- 4. Create skill_assessments table
-- ==================================================
CREATE TABLE IF NOT EXISTS `tbl_skill_assessments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `category_id` int NOT NULL,
  `target_audience` enum('student','professional','both') NOT NULL DEFAULT 'both',
  `question_count` int NOT NULL DEFAULT 10,
  `time_limit` int NOT NULL DEFAULT 600 COMMENT 'Time in seconds',
  `passing_score` int NOT NULL DEFAULT 70 COMMENT 'Percentage required to pass',
  `badge_id` int DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  KEY `target_audience` (`target_audience`),
  KEY `is_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==================================================
-- 5. Create user_assessments table
-- ==================================================
CREATE TABLE IF NOT EXISTS `tbl_user_assessments` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `assessment_id` int NOT NULL,
  `score` int NOT NULL DEFAULT 0,
  `total_questions` int NOT NULL,
  `correct_answers` int NOT NULL DEFAULT 0,
  `time_taken` int NOT NULL DEFAULT 0 COMMENT 'Time in seconds',
  `passed` tinyint(1) NOT NULL DEFAULT 0,
  `badge_earned` tinyint(1) NOT NULL DEFAULT 0,
  `completed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `user_id` (`user_id`),
  KEY `assessment_id` (`assessment_id`),
  KEY `passed` (`passed`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==================================================
-- 6. Create skill_assessment_questions mapping table
-- ==================================================
CREATE TABLE IF NOT EXISTS `tbl_skill_assessment_questions` (
  `id` int NOT NULL AUTO_INCREMENT,
  `assessment_id` int NOT NULL,
  `question_id` int NOT NULL,
  `question_order` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`),
  KEY `assessment_id` (`assessment_id`),
  KEY `question_id` (`question_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ==================================================
-- 7. Insert default professional categories
-- ==================================================
INSERT INTO `tbl_category` (`category_name`, `image`, `no_of`, `maxlevel`, `is_premium`, `target_audience`, `content_type`, `language_id`, `status`) 
VALUES
  ('Leadership & Management', '', '0', '3', '0', 'professional', 'workplace', '14', '1'),
  ('Workplace Communication', '', '0', '3', '0', 'professional', 'workplace', '14', '1'),
  ('Business Strategy', '', '0', '3', '0', 'professional', 'workplace', '14', '1'),
  ('Tech & AI Fundamentals', '', '0', '3', '0', 'both', 'skill', '14', '1'),
  ('Finance & Investment', '', '0', '3', '0', 'professional', 'skill', '14', '1'),
  ('Digital Marketing', '', '0', '3', '0', 'professional', 'skill', '14', '1'),
  ('Entrepreneurship', '', '0', '3', '0', 'professional', 'workplace', '14', '1'),
  ('Career & Interview Prep', '', '0', '3', '0', 'both', 'skill', '14', '1'),
  ('Workplace Scenarios', '', '0', '3', '0', 'professional', 'workplace', '14', '1')
ON DUPLICATE KEY UPDATE `category_name` = VALUES(`category_name`);

-- ==================================================
-- 8. Update existing academic categories
-- ==================================================
UPDATE `tbl_category` 
SET `target_audience` = 'student', `content_type` = 'academic' 
WHERE `category_name` IN ('Mathematics', 'Science', 'History', 'Geography', 'English', 'Physics', 'Chemistry', 'Biology');

-- ==================================================
-- 9. Insert settings for path system
-- ==================================================
INSERT INTO `tbl_settings` (`type`, `message`) 
VALUES
  ('path_switching_enabled', '1'),
  ('onboarding_demo_questions', '5'),
  ('default_path', 'student')
ON DUPLICATE KEY UPDATE `message` = VALUES(`message`);

-- ==================================================
-- Migration Complete
-- ==================================================
