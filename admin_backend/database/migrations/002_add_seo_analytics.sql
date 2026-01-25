-- Migration: Add SEO Analytics Tracking Table
-- Created: 2026-01-25
-- Description: Creates tbl_blog_seo_analytics table for tracking keyword generation and analytics

-- Create SEO Analytics tracking table
CREATE TABLE IF NOT EXISTS `tbl_blog_seo_analytics` (
    `id` INT(11) UNSIGNED NOT NULL AUTO_INCREMENT,
    `post_id` INT(11) NOT NULL,
    `keyword_source` ENUM('editor', 'auto') NOT NULL DEFAULT 'auto',
    `keywords_generated` VARCHAR(500) DEFAULT NULL,
    `keyword_count` INT(3) UNSIGNED NOT NULL DEFAULT 0,
    `ai_bot_hits` INT(11) UNSIGNED NOT NULL DEFAULT 0,
    `human_views` INT(11) UNSIGNED NOT NULL DEFAULT 0,
    `avg_time_on_page` INT(11) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Average time on page in seconds',
    `last_updated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    KEY `idx_post_id` (`post_id`),
    KEY `idx_keyword_source` (`keyword_source`),
    UNIQUE KEY `unique_post_seo` (`post_id`),
    CONSTRAINT `fk_blog_seo_post` FOREIGN KEY (`post_id`) REFERENCES `tbl_blog_posts`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Rollback SQL (if needed, run separately)
-- DROP TABLE IF EXISTS `tbl_blog_seo_analytics`;
