-- ========================================================
-- Blog System Database Schema
-- ========================================================
-- Created: 2026-01-20
-- Purpose: Support for blog functionality in mQuiz app
-- ========================================================

-- ========================================================
-- Table: tbl_blog_authors
-- Description: Store blog post authors
-- ========================================================
CREATE TABLE IF NOT EXISTS `tbl_blog_authors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) UNIQUE,
  `avatar` longtext,
  `bio` longtext,
  `social_links` json,
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- Table: tbl_blog_categories
-- Description: Blog post categories
-- ========================================================
CREATE TABLE IF NOT EXISTS `tbl_blog_categories` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL UNIQUE,
  `description` longtext,
  `color` varchar(7),
  `icon` varchar(255),
  `status` enum('active','inactive') DEFAULT 'active',
  `display_order` int(11) DEFAULT 0,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `status` (`status`),
  KEY `display_order` (`display_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- Table: tbl_blog_posts
-- Description: Main blog posts table
-- ========================================================
CREATE TABLE IF NOT EXISTS `tbl_blog_posts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL UNIQUE,
  `excerpt` longtext,
  `content` longtext NOT NULL,
  `featured_image` longtext,
  `category_id` int(11),
  `author_id` int(11),
  `featured` tinyint(1) DEFAULT 0,
  `status` enum('draft','published','archived') DEFAULT 'draft',
  `views` int(11) DEFAULT 0,
  `meta_title` varchar(255),
  `meta_description` longtext,
  `meta_keywords` longtext,
  `publish_date` datetime,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `slug` (`slug`),
  KEY `category_id` (`category_id`),
  KEY `author_id` (`author_id`),
  KEY `status` (`status`),
  KEY `featured` (`featured`),
  KEY `publish_date` (`publish_date`),
  CONSTRAINT `fk_blog_category` FOREIGN KEY (`category_id`) REFERENCES `tbl_blog_categories` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_blog_author` FOREIGN KEY (`author_id`) REFERENCES `tbl_blog_authors` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- Table: tbl_blog_post_tags
-- Description: Tags for blog posts (many-to-many)
-- ========================================================
CREATE TABLE IF NOT EXISTS `tbl_blog_post_tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) NOT NULL,
  `tag` varchar(100) NOT NULL,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `post_id` (`post_id`),
  KEY `tag` (`tag`),
  UNIQUE KEY `post_tag_unique` (`post_id`, `tag`),
  CONSTRAINT `fk_post_tags` FOREIGN KEY (`post_id`) REFERENCES `tbl_blog_posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- Table: tbl_blog_comments
-- Description: Comments on blog posts (for future use)
-- ========================================================
CREATE TABLE IF NOT EXISTS `tbl_blog_comments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `post_id` int(11) NOT NULL,
  `user_id` int(11),
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `content` longtext NOT NULL,
  `status` enum('pending','approved','spam') DEFAULT 'pending',
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `post_id` (`post_id`),
  KEY `user_id` (`user_id`),
  KEY `status` (`status`),
  CONSTRAINT `fk_comment_post` FOREIGN KEY (`post_id`) REFERENCES `tbl_blog_posts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ========================================================
-- Sample Data (Optional - for testing)
-- ========================================================

-- Insert sample author if none exists
INSERT IGNORE INTO `tbl_blog_authors` (`id`, `name`, `email`, `avatar`, `bio`, `status`) VALUES
(1, 'Admin', 'admin@mquiz.app', 'https://via.placeholder.com/150', 'mQuiz Administrator', 'active');

-- Insert sample categories
INSERT IGNORE INTO `tbl_blog_categories` (`id`, `slug`, `name`, `description`, `status`, `display_order`) VALUES
(1, 'learning-tips', 'Learning Tips', 'Tips and tricks for effective learning', 'active', 1),
(2, 'quiz-news', 'Quiz News', 'Latest news from mQuiz', 'active', 2),
(3, 'featured', 'Featured', 'Featured articles', 'active', 3),
(4, 'tutorials', 'Tutorials', 'How-to guides and tutorials', 'active', 4);
