-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: May 23, 2026 at 09:37 PM
-- Server version: 10.11.17-MariaDB
-- PHP Version: 8.4.21

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mquiz_d5bueportal`
--

-- --------------------------------------------------------

--
-- Table structure for table `tbl_ad_compliance_events`
--

CREATE TABLE `tbl_ad_compliance_events` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` int(11) NOT NULL,
  `firebase_id` varchar(255) DEFAULT NULL,
  `event_name` varchar(100) NOT NULL,
  `event_ts` datetime DEFAULT NULL,
  `event_payload` longtext DEFAULT NULL,
  `platform` varchar(20) DEFAULT NULL,
  `app_version` varchar(20) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `created_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_ai_questions`
--

CREATE TABLE `tbl_ai_questions` (
  `id` bigint(20) NOT NULL,
  `language_id` int(11) NOT NULL DEFAULT 0,
  `quiz_type` int(11) NOT NULL DEFAULT 0 COMMENT '1=quiz_zone,\r\n3=guess_the_word,\r\n6=multi_match,\r\n7=contest,\r\n8=exam',
  `contest_id` int(11) NOT NULL DEFAULT 0,
  `exam_id` int(11) NOT NULL DEFAULT 0,
  `category` int(11) NOT NULL,
  `subcategory` int(11) NOT NULL DEFAULT 0,
  `level` int(11) NOT NULL DEFAULT 0,
  `question_type` int(11) NOT NULL DEFAULT 0 COMMENT '1=options, 2=true/false',
  `answer_type` int(11) NOT NULL DEFAULT 0 COMMENT '1=multiselect, 2=sequence	',
  `question` text NOT NULL,
  `options` longtext NOT NULL,
  `correct_answer` varchar(50) NOT NULL,
  `marks` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 0,
  `note` varchar(255) DEFAULT NULL,
  `date_time` datetime NOT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_audio_question`
--

CREATE TABLE `tbl_audio_question` (
  `id` int(11) NOT NULL,
  `category` int(11) NOT NULL,
  `subcategory` int(11) NOT NULL,
  `language_id` int(11) NOT NULL DEFAULT 0,
  `audio_type` int(11) NOT NULL COMMENT '1=link,2=upload',
  `audio` varchar(255) NOT NULL,
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `question_type` tinyint(4) NOT NULL COMMENT '1=normal, 2=true/false',
  `optiona` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optionb` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optionc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optiond` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optione` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_authenticate`
--

CREATE TABLE `tbl_authenticate` (
  `auth_id` int(11) NOT NULL,
  `auth_username` varchar(12) NOT NULL,
  `auth_pass` text NOT NULL,
  `role` varchar(32) NOT NULL,
  `permissions` mediumtext NOT NULL,
  `status` int(11) NOT NULL DEFAULT 0,
  `language` varchar(255) DEFAULT NULL,
  `created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_badges`
--

CREATE TABLE `tbl_badges` (
  `id` int(11) NOT NULL,
  `language_id` int(11) DEFAULT 14,
  `type` varchar(100) NOT NULL,
  `badge_label` varchar(200) NOT NULL,
  `badge_note` text NOT NULL,
  `badge_reward` int(11) NOT NULL,
  `badge_icon` varchar(100) NOT NULL,
  `badge_counter` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_banner_impressions`
--

CREATE TABLE `tbl_banner_impressions` (
  `id` int(11) NOT NULL,
  `banner_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL COMMENT 'NULL for anonymous tracking',
  `action` enum('showed','clicked') DEFAULT 'showed',
  `recorded_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_battle_questions`
--

CREATE TABLE `tbl_battle_questions` (
  `id` int(11) NOT NULL,
  `match_id` varchar(128) NOT NULL,
  `entry_coin` int(11) NOT NULL DEFAULT 0,
  `questions` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `date_created` datetime NOT NULL,
  `set_user1` int(11) NOT NULL DEFAULT 0,
  `set_user2` int(11) NOT NULL DEFAULT 0
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_battle_statistics`
--

CREATE TABLE `tbl_battle_statistics` (
  `id` int(11) NOT NULL,
  `user_id1` int(11) NOT NULL,
  `user_id2` int(11) NOT NULL,
  `is_drawn` tinyint(4) NOT NULL,
  `winner_id` int(11) NOT NULL,
  `date_created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_blog_authors`
--

CREATE TABLE `tbl_blog_authors` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) DEFAULT NULL,
  `avatar` longtext DEFAULT NULL,
  `bio` longtext DEFAULT NULL,
  `social_links` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`social_links`)),
  `status` enum('active','inactive') DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_blog_categories`
--

CREATE TABLE `tbl_blog_categories` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` longtext DEFAULT NULL,
  `color` varchar(7) DEFAULT NULL,
  `icon` varchar(255) DEFAULT NULL,
  `status` enum('active','inactive') DEFAULT 'active',
  `display_order` int(11) DEFAULT 0,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_blog_comments`
--

CREATE TABLE `tbl_blog_comments` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `content` longtext NOT NULL,
  `status` enum('pending','approved','spam') DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_blog_posts`
--

CREATE TABLE `tbl_blog_posts` (
  `id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `excerpt` longtext DEFAULT NULL,
  `content` longtext NOT NULL,
  `featured_image` longtext DEFAULT NULL,
  `category_id` int(11) DEFAULT NULL,
  `author_id` int(11) DEFAULT NULL,
  `featured` tinyint(1) DEFAULT 0,
  `status` enum('draft','published','archived') DEFAULT 'draft',
  `views` int(11) DEFAULT 0,
  `meta_title` varchar(255) DEFAULT NULL,
  `meta_description` longtext DEFAULT NULL,
  `meta_keywords` longtext DEFAULT NULL,
  `publish_date` datetime DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_blog_post_tags`
--

CREATE TABLE `tbl_blog_post_tags` (
  `id` int(11) NOT NULL,
  `post_id` int(11) NOT NULL,
  `tag` varchar(100) NOT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_blog_seo_analytics`
--

CREATE TABLE `tbl_blog_seo_analytics` (
  `id` int(10) UNSIGNED NOT NULL,
  `post_id` int(11) NOT NULL,
  `keyword_source` enum('editor','auto') NOT NULL DEFAULT 'auto',
  `keywords_generated` varchar(500) DEFAULT NULL,
  `keyword_count` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `ai_bot_hits` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `human_views` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `avg_time_on_page` int(10) UNSIGNED NOT NULL DEFAULT 0 COMMENT 'Average time on page in seconds',
  `last_updated` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_bookmark`
--

CREATE TABLE `tbl_bookmark` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `type` int(11) NOT NULL COMMENT '1-quiz_zone, 3-guess_the_word, 4-audio_question'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_cache`
--

CREATE TABLE `tbl_cache` (
  `id` int(11) NOT NULL,
  `cache_key` varchar(255) NOT NULL,
  `cache_data` text NOT NULL,
  `cache_expiry` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_category`
--

CREATE TABLE `tbl_category` (
  `id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL DEFAULT 0,
  `category_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `slug` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `type` int(11) NOT NULL,
  `is_premium` tinyint(4) NOT NULL DEFAULT 0 COMMENT '0 - no , 1 - yes',
  `coins` int(11) NOT NULL DEFAULT 0,
  `image` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `row_order` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_coin_store`
--

CREATE TABLE `tbl_coin_store` (
  `id` int(11) NOT NULL,
  `title` varchar(50) NOT NULL,
  `coins` int(11) NOT NULL,
  `type` int(11) NOT NULL DEFAULT 0 COMMENT '1=ads',
  `product_id` varchar(150) NOT NULL,
  `image` text DEFAULT NULL,
  `description` text NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '0 - OFF , 1 - ON'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_contest`
--

CREATE TABLE `tbl_contest` (
  `id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL DEFAULT 0,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `image` varchar(512) NOT NULL,
  `entry` int(11) NOT NULL,
  `prize_status` int(11) NOT NULL,
  `date_created` datetime NOT NULL,
  `status` int(11) NOT NULL COMMENT '0=deactive,1=active'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_contest_leaderboard`
--

CREATE TABLE `tbl_contest_leaderboard` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `contest_id` int(11) NOT NULL,
  `questions_attended` int(11) NOT NULL,
  `correct_answers` int(11) NOT NULL,
  `score` double NOT NULL,
  `last_updated` datetime NOT NULL,
  `date_created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_contest_prize`
--

CREATE TABLE `tbl_contest_prize` (
  `id` int(11) NOT NULL,
  `contest_id` int(11) NOT NULL,
  `top_winner` int(11) NOT NULL,
  `points` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_contest_question`
--

CREATE TABLE `tbl_contest_question` (
  `id` int(11) NOT NULL,
  `langauge_id` int(11) NOT NULL DEFAULT 0,
  `contest_id` int(11) NOT NULL,
  `image` varchar(256) NOT NULL,
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `question_type` int(11) NOT NULL COMMENT '1= normal, 2= true/false',
  `optiona` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optionb` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optionc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optiond` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optione` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `answer` varchar(12) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_country_region_mapping`
--

CREATE TABLE `tbl_country_region_mapping` (
  `id` int(11) NOT NULL,
  `country_code` varchar(3) NOT NULL,
  `country_name` varchar(100) NOT NULL,
  `continent` varchar(50) NOT NULL,
  `region_code` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_daily_quiz`
--

CREATE TABLE `tbl_daily_quiz` (
  `id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `questions_id` text NOT NULL,
  `date_published` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_daily_quiz_user`
--

CREATE TABLE `tbl_daily_quiz_user` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `date` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_daily_streak`
--

CREATE TABLE `tbl_daily_streak` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `last_login_date` date DEFAULT NULL,
  `streak_count` int(11) DEFAULT 0 COMMENT 'Current active streak days',
  `max_streak` int(11) DEFAULT 0 COMMENT 'All-time maximum streak',
  `coin_earned_today` int(11) DEFAULT 0 COMMENT 'Coins earned on this login day',
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_device_mapping`
--

CREATE TABLE `tbl_device_mapping` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `device_id` varchar(255) NOT NULL COMMENT 'Firebase Device ID or unique device fingerprint',
  `device_type` varchar(20) DEFAULT NULL COMMENT 'android or ios',
  `device_name` varchar(255) DEFAULT NULL,
  `first_login` timestamp NULL DEFAULT current_timestamp(),
  `last_login` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  `status` enum('active','suspended') DEFAULT 'active',
  `suspension_reason` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_exam_module`
--

CREATE TABLE `tbl_exam_module` (
  `id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL DEFAULT 0,
  `title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `date` date NOT NULL,
  `exam_key` varchar(100) NOT NULL,
  `duration` int(11) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 0,
  `answer_again` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_exam_module_question`
--

CREATE TABLE `tbl_exam_module_question` (
  `id` int(11) NOT NULL,
  `exam_module_id` int(11) NOT NULL,
  `image` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `marks` int(11) NOT NULL,
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `question_type` tinyint(4) NOT NULL COMMENT '1=normal, 2=true/false',
  `optiona` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optionb` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optionc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optiond` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optione` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_exam_module_result`
--

CREATE TABLE `tbl_exam_module_result` (
  `id` int(11) NOT NULL,
  `exam_module_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `obtained_marks` varchar(200) NOT NULL,
  `total_duration` varchar(20) NOT NULL,
  `statistics` longtext NOT NULL,
  `status` int(11) NOT NULL COMMENT '2-in_exam, 3-completed',
  `rules_violated` tinyint(4) NOT NULL,
  `captured_question_ids` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_fraud_detection`
--

CREATE TABLE `tbl_fraud_detection` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `detection_type` enum('ad_spam','quiz_speed','multi_account','instant_withdraw','unusual_pattern') DEFAULT 'unusual_pattern',
  `reason` varchar(255) NOT NULL,
  `severity` enum('low','medium','high','critical') DEFAULT 'low',
  `action_taken` enum('none','review','warning','suspend') DEFAULT 'none',
  `action_date` timestamp NULL DEFAULT NULL,
  `metadata` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL COMMENT 'Additional detection data (e.g., ad count, accuracy %)' CHECK (json_valid(`metadata`)),
  `resolved` tinyint(4) DEFAULT 0,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `resolution_notes` varchar(500) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_fun_n_learn`
--

CREATE TABLE `tbl_fun_n_learn` (
  `id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL DEFAULT 0,
  `category` int(11) NOT NULL,
  `subcategory` int(11) NOT NULL,
  `title` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `detail` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `status` int(11) NOT NULL DEFAULT 0,
  `content_type` tinyint(4) NOT NULL DEFAULT 0,
  `content_data` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_fun_n_learn_question`
--

CREATE TABLE `tbl_fun_n_learn_question` (
  `id` int(11) NOT NULL,
  `fun_n_learn_id` int(11) NOT NULL,
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `question_type` int(11) NOT NULL COMMENT '1= normal, 2= true/false',
  `optiona` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optionb` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optionc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optiond` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optione` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `answer` varchar(12) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `image` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_guess_the_word`
--

CREATE TABLE `tbl_guess_the_word` (
  `id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `category` int(11) NOT NULL,
  `subcategory` int(11) NOT NULL,
  `image` text NOT NULL,
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_languages`
--

CREATE TABLE `tbl_languages` (
  `id` int(11) NOT NULL,
  `language` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `code` varchar(11) NOT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 0 COMMENT '1=Enabled, 0=Disabled',
  `type` tinyint(4) NOT NULL DEFAULT 0 COMMENT '1=active, 0=deactive',
  `default_active` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_leaderboard_daily`
--

CREATE TABLE `tbl_leaderboard_daily` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `score` int(11) NOT NULL,
  `date_created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_leaderboard_engagement_alltime`
--

CREATE TABLE `tbl_leaderboard_engagement_alltime` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `total_minutes` decimal(10,2) NOT NULL DEFAULT 0.00,
  `last_updated` datetime NOT NULL,
  `date_created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_leaderboard_engagement_monthly`
--

CREATE TABLE `tbl_leaderboard_engagement_monthly` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `total_minutes` decimal(10,2) NOT NULL DEFAULT 0.00,
  `month` int(11) NOT NULL,
  `year` int(11) NOT NULL,
  `last_updated` datetime NOT NULL,
  `date_created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_leaderboard_engagement_weekly`
--

CREATE TABLE `tbl_leaderboard_engagement_weekly` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `total_minutes` decimal(10,2) NOT NULL DEFAULT 0.00,
  `week_number` int(11) NOT NULL,
  `year` int(11) NOT NULL,
  `last_updated` datetime NOT NULL,
  `date_created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_leaderboard_monthly`
--

CREATE TABLE `tbl_leaderboard_monthly` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `score` int(11) NOT NULL,
  `last_updated` datetime NOT NULL,
  `date_created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_leaderboard_weekly`
--

CREATE TABLE `tbl_leaderboard_weekly` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `score` int(11) NOT NULL DEFAULT 0,
  `week_number` int(11) NOT NULL,
  `year` int(11) NOT NULL,
  `last_updated` datetime NOT NULL,
  `date_created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_league`
--

CREATE TABLE `tbl_league` (
  `id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL DEFAULT 0,
  `name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `image` varchar(255) DEFAULT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `entry` int(11) NOT NULL DEFAULT 0 COMMENT 'entry coins',
  `created_by` int(11) NOT NULL DEFAULT 0,
  `prize_status` int(11) NOT NULL DEFAULT 0 COMMENT '0=not distributed,1=distributed',
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0=deactive,1=active',
  `date_created` datetime NOT NULL DEFAULT current_timestamp(),
  `date_updated` datetime DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_league_daily_quiz`
--

CREATE TABLE `tbl_league_daily_quiz` (
  `id` int(11) NOT NULL,
  `league_id` int(11) NOT NULL,
  `quiz_day` int(11) NOT NULL COMMENT '1..N day in league',
  `quiz_date` date NOT NULL,
  `question_count` int(11) NOT NULL DEFAULT 20,
  `date_assigned` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_league_daily_quiz_questions`
--

CREATE TABLE `tbl_league_daily_quiz_questions` (
  `id` int(11) NOT NULL,
  `daily_quiz_id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `question_order` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_league_leaderboard`
--

CREATE TABLE `tbl_league_leaderboard` (
  `id` int(11) NOT NULL,
  `league_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `cumulative_best_score` double NOT NULL DEFAULT 0,
  `daily_best_scores` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`daily_best_scores`)),
  `games_played` int(11) NOT NULL DEFAULT 0,
  `rank` int(11) DEFAULT NULL,
  `last_updated` datetime NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `date_created` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_league_notification_log`
--

CREATE TABLE `tbl_league_notification_log` (
  `id` int(11) NOT NULL,
  `league_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `notification_type` varchar(50) NOT NULL COMMENT 'pre-league,start-day',
  `status` varchar(20) NOT NULL DEFAULT 'sent' COMMENT 'sent,failed,skipped',
  `sent_at` datetime DEFAULT NULL,
  `device_token` varchar(512) DEFAULT NULL,
  `error_message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `date_created` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_league_prize`
--

CREATE TABLE `tbl_league_prize` (
  `id` int(11) NOT NULL,
  `league_id` int(11) NOT NULL,
  `top_winner` int(11) NOT NULL COMMENT '1,2,3',
  `points` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_league_submission`
--

CREATE TABLE `tbl_league_submission` (
  `id` int(11) NOT NULL,
  `league_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `daily_quiz_id` int(11) NOT NULL,
  `quiz_day` int(11) NOT NULL,
  `score` double NOT NULL DEFAULT 0,
  `correct_answers` int(11) NOT NULL DEFAULT 0,
  `wrong_answers` int(11) NOT NULL DEFAULT 0,
  `total_questions` int(11) NOT NULL DEFAULT 0,
  `ad_shown` tinyint(4) NOT NULL DEFAULT 0,
  `submission_date` date NOT NULL,
  `submitted_at` datetime NOT NULL DEFAULT current_timestamp(),
  `date_created` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_league_user`
--

CREATE TABLE `tbl_league_user` (
  `id` int(11) NOT NULL,
  `league_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `status` varchar(20) NOT NULL DEFAULT 'opt-in' COMMENT 'opt-in,active,withdrawn',
  `opted_in_at` datetime DEFAULT NULL,
  `joined_at` datetime DEFAULT NULL,
  `coins_paid` int(11) NOT NULL DEFAULT 0,
  `device_token` varchar(512) DEFAULT NULL,
  `notifications_enabled` tinyint(4) NOT NULL DEFAULT 1,
  `date_created` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_level`
--

CREATE TABLE `tbl_level` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `category` int(11) NOT NULL,
  `subcategory` int(11) NOT NULL,
  `level` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_maths_question`
--

CREATE TABLE `tbl_maths_question` (
  `id` int(11) NOT NULL,
  `category` int(11) NOT NULL,
  `subcategory` int(11) NOT NULL,
  `language_id` int(11) NOT NULL DEFAULT 0,
  `image` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `question_type` tinyint(4) NOT NULL COMMENT '1=normal, 2=true/false',
  `optiona` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optionb` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optionc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optiond` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optione` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_month_week`
--

CREATE TABLE `tbl_month_week` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `type` int(11) NOT NULL COMMENT '1=month,2=week'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_multi_match`
--

CREATE TABLE `tbl_multi_match` (
  `id` int(11) NOT NULL,
  `category` int(11) NOT NULL,
  `subcategory` int(11) NOT NULL,
  `language_id` int(11) NOT NULL DEFAULT 0,
  `image` varchar(250) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `question_type` tinyint(4) NOT NULL COMMENT '1=normal, 2=true/false',
  `optiona` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optionb` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optionc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optiond` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optione` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `answer_type` tinyint(4) NOT NULL COMMENT '1=multiselect,2=sequence',
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `level` int(11) NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_multi_match_level`
--

CREATE TABLE `tbl_multi_match_level` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `category` int(11) NOT NULL,
  `subcategory` int(11) NOT NULL,
  `level` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_multi_match_question_reports`
--

CREATE TABLE `tbl_multi_match_question_reports` (
  `id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `message` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `date` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_notifications`
--

CREATE TABLE `tbl_notifications` (
  `id` int(11) NOT NULL,
  `title` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `users` varchar(8) NOT NULL DEFAULT 'all',
  `user_id` longtext DEFAULT NULL,
  `type` varchar(250) NOT NULL,
  `type_id` int(11) NOT NULL,
  `image` varchar(128) NOT NULL,
  `date_sent` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_payment_request`
--

CREATE TABLE `tbl_payment_request` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `uid` text NOT NULL,
  `payment_type` varchar(100) NOT NULL,
  `payment_address` varchar(225) NOT NULL,
  `payment_amount` varchar(20) NOT NULL,
  `coin_used` varchar(20) NOT NULL,
  `details` text NOT NULL,
  `status` tinyint(4) NOT NULL COMMENT '0-pending, 1-completed, 2-invalid details',
  `date` datetime NOT NULL,
  `status_date` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_question`
--

CREATE TABLE `tbl_question` (
  `id` int(11) NOT NULL,
  `category` int(11) NOT NULL,
  `subcategory` int(11) NOT NULL,
  `language_id` int(11) NOT NULL DEFAULT 0,
  `image` varchar(512) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `question` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `question_type` tinyint(4) NOT NULL COMMENT '1=normal, 2=true/false',
  `optiona` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optionb` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optionc` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optiond` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `optione` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `answer` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `level` int(11) NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_question_reports`
--

CREATE TABLE `tbl_question_reports` (
  `id` int(11) NOT NULL,
  `question_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `message` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `date` datetime NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_quiz_categories`
--

CREATE TABLE `tbl_quiz_categories` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `type` int(11) NOT NULL COMMENT '2-fun_n_learn, 3-guess_the_word, 4-audio_question',
  `type_id` int(11) NOT NULL,
  `category` int(11) NOT NULL,
  `subcategory` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_referrals`
--

CREATE TABLE `tbl_referrals` (
  `id` int(11) NOT NULL,
  `referrer_id` int(11) NOT NULL COMMENT 'User who shared the referral code',
  `referrer_uid` varchar(255) DEFAULT NULL,
  `referee_id` int(11) NOT NULL COMMENT 'User who signed up using referral code',
  `referee_uid` varchar(255) DEFAULT NULL,
  `referral_code` varchar(50) NOT NULL,
  `signup_date` timestamp NULL DEFAULT current_timestamp(),
  `signup_ip` varchar(45) DEFAULT NULL COMMENT 'IP address at signup',
  `signup_device_id` varchar(255) DEFAULT NULL COMMENT 'Device fingerprint',
  `referee_active_days` int(11) DEFAULT 0 COMMENT 'Number of days referee has been active',
  `referee_quizzes_played` int(11) DEFAULT 0 COMMENT 'Total quizzes played by referee',
  `referee_coins_earned` int(11) DEFAULT 0 COMMENT 'Total coins earned by referee',
  `status` enum('pending','qualified','rewarded','rejected') DEFAULT 'pending',
  `qualified_date` timestamp NULL DEFAULT NULL COMMENT 'Date when referee met requirements',
  `reward_date` timestamp NULL DEFAULT NULL COMMENT 'Date when rewards were given',
  `rejection_reason` varchar(255) DEFAULT NULL COMMENT 'Why referral was rejected (fraud, duplicate, etc)',
  `referrer_coins_rewarded` int(11) DEFAULT 0,
  `referee_coins_rewarded` int(11) DEFAULT 0,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Triggers `tbl_referrals`
--
DELIMITER $$
CREATE TRIGGER `trg_check_duplicate_device` AFTER INSERT ON `tbl_referrals` FOR EACH ROW BEGIN
    DECLARE v_device_count INT;
    DECLARE v_max_per_device INT;
    SELECT message INTO v_max_per_device FROM tbl_settings WHERE type = 'referral_max_per_device';
    -- Count referrals from same device
    SELECT COUNT(*) INTO v_device_count
    FROM tbl_referrals
    WHERE signup_device_id = NEW.signup_device_id
    AND id != NEW.id;
    -- If exceeds limit, log fraud
    IF v_device_count >= v_max_per_device THEN
        INSERT INTO tbl_referral_fraud_checks (referral_id, check_type, severity, details)
        VALUES (NEW.id, 'same_device_multiple_accounts', 'critical', 
                JSON_OBJECT('device_id', NEW.signup_device_id, 'count', v_device_count + 1));
    END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `trg_check_duplicate_ip` AFTER INSERT ON `tbl_referrals` FOR EACH ROW BEGIN
    DECLARE v_ip_count INT;
    DECLARE v_max_same_ip INT;
    SELECT message INTO v_max_same_ip FROM tbl_settings WHERE type = 'referral_same_ip_max_count';
    -- Count referrals from same IP
    SELECT COUNT(*) INTO v_ip_count
    FROM tbl_referrals
    WHERE signup_ip = NEW.signup_ip
    AND id != NEW.id;
    -- If exceeds limit, log fraud
    IF v_ip_count >= v_max_same_ip THEN
        INSERT INTO tbl_referral_fraud_checks (referral_id, check_type, severity, details)
        VALUES (NEW.id, 'duplicate_ip', 'high', 
                JSON_OBJECT('ip', NEW.signup_ip, 'count', v_ip_count + 1));
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_referral_activity`
--

CREATE TABLE `tbl_referral_activity` (
  `id` int(11) NOT NULL,
  `referral_id` int(11) NOT NULL COMMENT 'FK to tbl_referrals',
  `referee_id` int(11) NOT NULL,
  `activity_date` date NOT NULL,
  `quizzes_played` int(11) DEFAULT 0,
  `coins_earned` int(11) DEFAULT 0,
  `time_spent_seconds` int(11) DEFAULT 0,
  `is_active_day` tinyint(4) DEFAULT 0 COMMENT '1 if played at least 1 quiz',
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_referral_codes`
--

CREATE TABLE `tbl_referral_codes` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `referral_code` varchar(50) NOT NULL,
  `total_referrals` int(11) DEFAULT 0,
  `successful_referrals` int(11) DEFAULT 0 COMMENT 'Referrals that qualified',
  `total_coins_earned` int(11) DEFAULT 0,
  `is_active` tinyint(4) DEFAULT 1,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_referral_fraud_checks`
--

CREATE TABLE `tbl_referral_fraud_checks` (
  `id` int(11) NOT NULL,
  `referral_id` int(11) NOT NULL,
  `check_type` enum('duplicate_ip','duplicate_device','same_device_multiple_accounts','rapid_signups','fake_activity','suspicious_pattern') NOT NULL,
  `severity` enum('low','medium','high','critical') DEFAULT 'medium',
  `details` text DEFAULT NULL COMMENT 'JSON data with fraud details',
  `detected_at` timestamp NULL DEFAULT current_timestamp(),
  `resolved` tinyint(4) DEFAULT 0,
  `resolved_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_rooms`
--

CREATE TABLE `tbl_rooms` (
  `id` int(11) NOT NULL,
  `room_id` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `entry_coin` int(11) NOT NULL DEFAULT 0,
  `user_id` int(11) NOT NULL,
  `room_type` varchar(11) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `category_id` int(11) NOT NULL,
  `no_of_que` int(11) NOT NULL,
  `questions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `date_created` datetime NOT NULL,
  `set_user1` int(11) NOT NULL DEFAULT 0,
  `set_user2` int(11) NOT NULL DEFAULT 0,
  `set_user3` int(11) NOT NULL DEFAULT 0,
  `set_user4` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_settings`
--

CREATE TABLE `tbl_settings` (
  `id` int(11) NOT NULL,
  `type` varchar(512) NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_slider`
--

CREATE TABLE `tbl_slider` (
  `id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `image` varchar(255) NOT NULL,
  `title` text NOT NULL,
  `description` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_sponsor_banners`
--

CREATE TABLE `tbl_sponsor_banners` (
  `id` int(11) NOT NULL,
  `sponsor_name` varchar(255) NOT NULL,
  `title` varchar(255) DEFAULT NULL,
  `image_url` varchar(500) DEFAULT NULL,
  `image_path` varchar(500) DEFAULT NULL COMMENT 'Local storage path',
  `redirect_url` varchar(500) DEFAULT NULL COMMENT 'URL opened on banner click',
  `redirect_type` enum('url','appstore','custom') DEFAULT 'url',
  `impression_limit` int(11) DEFAULT 0 COMMENT '0 = unlimited impressions',
  `impression_period` enum('daily','weekly','monthly') DEFAULT 'daily',
  `current_impressions` int(11) DEFAULT 0,
  `impression_reset_date` date DEFAULT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime NOT NULL,
  `is_active` tinyint(4) DEFAULT 1,
  `priority` int(11) DEFAULT 0 COMMENT 'Higher priority shown first',
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT NULL ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_subcategory`
--

CREATE TABLE `tbl_subcategory` (
  `id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL DEFAULT 0,
  `maincat_id` int(11) NOT NULL,
  `subcategory_name` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `slug` varchar(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `image` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `status` tinyint(4) NOT NULL DEFAULT 1 COMMENT '1=Active, 0=Deactive',
  `is_premium` tinyint(4) NOT NULL DEFAULT 0 COMMENT '0 - no , 1 - yes',
  `coins` int(11) NOT NULL DEFAULT 0,
  `row_order` int(11) NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_tracker`
--

CREATE TABLE `tbl_tracker` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `uid` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `points` varchar(255) NOT NULL,
  `type` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `status` tinyint(4) NOT NULL COMMENT '0-add, 1-deduct',
  `date` date NOT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_upload_languages`
--

CREATE TABLE `tbl_upload_languages` (
  `id` int(11) NOT NULL,
  `name` varchar(512) NOT NULL,
  `title` varchar(512) NOT NULL,
  `app_version` varchar(100) NOT NULL DEFAULT '0',
  `web_version` varchar(100) NOT NULL DEFAULT '0',
  `app_rtl_support` tinyint(4) NOT NULL DEFAULT 0,
  `web_rtl_support` tinyint(4) NOT NULL DEFAULT 0,
  `app_status` tinyint(4) NOT NULL DEFAULT 0,
  `web_status` tinyint(4) NOT NULL DEFAULT 0,
  `app_default` tinyint(4) NOT NULL DEFAULT 0,
  `web_default` tinyint(4) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_users`
--

CREATE TABLE `tbl_users` (
  `id` int(10) UNSIGNED NOT NULL,
  `firebase_id` longtext CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL DEFAULT '',
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `country_code` varchar(3) DEFAULT NULL,
  `country_name` varchar(100) DEFAULT NULL,
  `continent` varchar(50) DEFAULT NULL,
  `region_auto_detected` tinyint(1) DEFAULT 1,
  `mobile` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `type` varchar(16) NOT NULL,
  `profile` varchar(128) NOT NULL,
  `fcm_id` varchar(1024) DEFAULT NULL,
  `web_fcm_id` varchar(1024) DEFAULT NULL,
  `coins` int(11) NOT NULL DEFAULT 0,
  `refer_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `friends_code` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  `remove_ads` tinyint(4) NOT NULL DEFAULT 0,
  `daily_ads_counter` int(11) NOT NULL DEFAULT 0 COMMENT 'Daily ads counter',
  `daily_ads_date` date NOT NULL DEFAULT '2023-10-19' COMMENT 'Daily ads date',
  `status` int(10) UNSIGNED DEFAULT 0,
  `date_registered` datetime NOT NULL,
  `api_token` longtext NOT NULL,
  `app_language` varchar(512) DEFAULT NULL,
  `web_language` varchar(512) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_users_badges`
--

CREATE TABLE `tbl_users_badges` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `dashing_debut` int(11) NOT NULL,
  `dashing_debut_counter` int(11) NOT NULL,
  `combat_winner` int(11) NOT NULL,
  `combat_winner_counter` int(11) NOT NULL,
  `clash_winner` int(11) NOT NULL,
  `clash_winner_counter` int(11) NOT NULL,
  `most_wanted_winner` int(11) NOT NULL,
  `most_wanted_winner_counter` int(11) NOT NULL,
  `ultimate_player` int(11) NOT NULL,
  `quiz_warrior` int(11) NOT NULL,
  `quiz_warrior_counter` int(11) NOT NULL,
  `super_sonic` int(11) NOT NULL,
  `flashback` int(11) NOT NULL,
  `brainiac` int(11) NOT NULL,
  `big_thing` int(11) NOT NULL,
  `elite` int(11) NOT NULL,
  `thirsty` int(11) NOT NULL,
  `thirsty_date` date DEFAULT NULL,
  `thirsty_counter` int(11) NOT NULL,
  `power_elite` int(11) NOT NULL,
  `power_elite_counter` int(11) NOT NULL,
  `sharing_caring` int(11) NOT NULL,
  `streak` int(11) NOT NULL,
  `streak_date` date DEFAULT NULL,
  `streak_counter` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_users_in_app`
--

CREATE TABLE `tbl_users_in_app` (
  `id` int(11) NOT NULL,
  `pay_from` tinyint(4) NOT NULL COMMENT '1=android,2=ios',
  `uid` longtext NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` text NOT NULL,
  `amount` int(11) NOT NULL,
  `status` varchar(50) NOT NULL,
  `transaction_id` text NOT NULL,
  `date` datetime NOT NULL,
  `purchase_token` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `responseData` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_users_statistics`
--

CREATE TABLE `tbl_users_statistics` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `questions_answered` int(11) NOT NULL,
  `correct_answers` int(11) NOT NULL,
  `strong_category` int(11) NOT NULL,
  `ratio1` double NOT NULL,
  `weak_category` int(11) NOT NULL,
  `ratio2` double NOT NULL,
  `best_position` int(11) NOT NULL,
  `date_created` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_audio_quiz_session`
--

CREATE TABLE `tbl_user_audio_quiz_session` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `questions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `date` date DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_category`
--

CREATE TABLE `tbl_user_category` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_contest_session`
--

CREATE TABLE `tbl_user_contest_session` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `questions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `date` date DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_daily_quiz_session`
--

CREATE TABLE `tbl_user_daily_quiz_session` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `questions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `date` date DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_engagement`
--

CREATE TABLE `tbl_user_engagement` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `session_start` datetime NOT NULL,
  `session_end` datetime DEFAULT NULL,
  `duration_seconds` int(11) NOT NULL DEFAULT 0,
  `date_created` date NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_fun_n_learn_session`
--

CREATE TABLE `tbl_user_fun_n_learn_session` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `questions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `date` date DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_guess_the_word_session`
--

CREATE TABLE `tbl_user_guess_the_word_session` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `questions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `date` date DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_maths_quiz_session`
--

CREATE TABLE `tbl_user_maths_quiz_session` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `questions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `date` date DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_multi_match_session`
--

CREATE TABLE `tbl_user_multi_match_session` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `questions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `date` date DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_quiz_zone_session`
--

CREATE TABLE `tbl_user_quiz_zone_session` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `questions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `date` date DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_subcategory`
--

CREATE TABLE `tbl_user_subcategory` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `subcategory_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user_true_false_session`
--

CREATE TABLE `tbl_user_true_false_session` (
  `id` bigint(20) NOT NULL,
  `user_id` int(11) NOT NULL,
  `questions` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL,
  `date` date DEFAULT NULL
) ;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_web_settings`
--

CREATE TABLE `tbl_web_settings` (
  `id` int(11) NOT NULL,
  `language_id` int(11) DEFAULT 14,
  `type` varchar(32) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `message` text CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_referral_stats`
-- (See below for the actual view)
--
CREATE TABLE `vw_referral_stats` (
`user_id` int(11)
,`referral_code` varchar(50)
,`total_referrals` int(11)
,`successful_referrals` int(11)
,`total_coins_earned` int(11)
,`pending_referrals` bigint(21)
,`qualified_referrals` bigint(21)
,`rewarded_referrals` bigint(21)
,`rejected_referrals` bigint(21)
);

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_suspicious_referrals`
-- (See below for the actual view)
--
CREATE TABLE `vw_suspicious_referrals` (
`referral_id` int(11)
,`referrer_id` int(11)
,`referee_id` int(11)
,`referral_code` varchar(50)
,`signup_ip` varchar(45)
,`signup_device_id` varchar(255)
,`status` enum('pending','qualified','rewarded','rejected')
,`fraud_flags` bigint(21)
,`fraud_types` mediumtext
,`max_severity` enum('low','medium','high','critical')
);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_ad_compliance_events`
--
ALTER TABLE `tbl_ad_compliance_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_ad_compliance_user_id` (`user_id`),
  ADD KEY `idx_ad_compliance_event_name` (`event_name`),
  ADD KEY `idx_ad_compliance_created_at` (`created_at`);

--
-- Indexes for table `tbl_ai_questions`
--
ALTER TABLE `tbl_ai_questions`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_audio_question`
--
ALTER TABLE `tbl_audio_question`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category` (`category`),
  ADD KEY `subcategory` (`subcategory`) USING BTREE,
  ADD KEY `language_id` (`language_id`);

--
-- Indexes for table `tbl_authenticate`
--
ALTER TABLE `tbl_authenticate`
  ADD PRIMARY KEY (`auth_id`),
  ADD UNIQUE KEY `auth_username` (`auth_username`);

--
-- Indexes for table `tbl_badges`
--
ALTER TABLE `tbl_badges`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_banner_impressions`
--
ALTER TABLE `tbl_banner_impressions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_banner_id` (`banner_id`),
  ADD KEY `idx_banner_date` (`banner_id`,`recorded_at`),
  ADD KEY `idx_user` (`user_id`);

--
-- Indexes for table `tbl_battle_questions`
--
ALTER TABLE `tbl_battle_questions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `match_id` (`match_id`);

--
-- Indexes for table `tbl_battle_statistics`
--
ALTER TABLE `tbl_battle_statistics`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id1` (`user_id1`),
  ADD KEY `user_id2` (`user_id2`);

--
-- Indexes for table `tbl_blog_authors`
--
ALTER TABLE `tbl_blog_authors`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `tbl_blog_categories`
--
ALTER TABLE `tbl_blog_categories`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `status` (`status`),
  ADD KEY `display_order` (`display_order`);

--
-- Indexes for table `tbl_blog_comments`
--
ALTER TABLE `tbl_blog_comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `post_id` (`post_id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `status` (`status`);

--
-- Indexes for table `tbl_blog_posts`
--
ALTER TABLE `tbl_blog_posts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`),
  ADD KEY `category_id` (`category_id`),
  ADD KEY `author_id` (`author_id`),
  ADD KEY `status` (`status`),
  ADD KEY `featured` (`featured`),
  ADD KEY `publish_date` (`publish_date`);

--
-- Indexes for table `tbl_blog_post_tags`
--
ALTER TABLE `tbl_blog_post_tags`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `post_tag_unique` (`post_id`,`tag`),
  ADD KEY `post_id` (`post_id`),
  ADD KEY `tag` (`tag`);

--
-- Indexes for table `tbl_blog_seo_analytics`
--
ALTER TABLE `tbl_blog_seo_analytics`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_post_seo` (`post_id`),
  ADD KEY `idx_post_id` (`post_id`),
  ADD KEY `idx_keyword_source` (`keyword_source`);

--
-- Indexes for table `tbl_bookmark`
--
ALTER TABLE `tbl_bookmark`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `question_id` (`question_id`);

--
-- Indexes for table `tbl_cache`
--
ALTER TABLE `tbl_cache`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `cache_key` (`cache_key`),
  ADD KEY `cache_expiry` (`cache_expiry`);

--
-- Indexes for table `tbl_category`
--
ALTER TABLE `tbl_category`
  ADD PRIMARY KEY (`id`),
  ADD KEY `language_id` (`language_id`);

--
-- Indexes for table `tbl_coin_store`
--
ALTER TABLE `tbl_coin_store`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `product_id` (`product_id`);

--
-- Indexes for table `tbl_contest`
--
ALTER TABLE `tbl_contest`
  ADD PRIMARY KEY (`id`),
  ADD KEY `language_id` (`language_id`);

--
-- Indexes for table `tbl_contest_leaderboard`
--
ALTER TABLE `tbl_contest_leaderboard`
  ADD PRIMARY KEY (`id`),
  ADD KEY `score` (`score`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `contest_id` (`contest_id`);

--
-- Indexes for table `tbl_contest_prize`
--
ALTER TABLE `tbl_contest_prize`
  ADD PRIMARY KEY (`id`),
  ADD KEY `contest_id` (`contest_id`);

--
-- Indexes for table `tbl_contest_question`
--
ALTER TABLE `tbl_contest_question`
  ADD PRIMARY KEY (`id`),
  ADD KEY `contest_id` (`contest_id`) USING BTREE;

--
-- Indexes for table `tbl_country_region_mapping`
--
ALTER TABLE `tbl_country_region_mapping`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_country_code` (`country_code`),
  ADD KEY `idx_continent` (`continent`);

--
-- Indexes for table `tbl_daily_quiz`
--
ALTER TABLE `tbl_daily_quiz`
  ADD PRIMARY KEY (`id`),
  ADD KEY `language_id` (`language_id`);

--
-- Indexes for table `tbl_daily_quiz_user`
--
ALTER TABLE `tbl_daily_quiz_user`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_daily_streak`
--
ALTER TABLE `tbl_daily_streak`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_user_date` (`user_id`,`last_login_date`),
  ADD KEY `idx_updated` (`updated_at`);

--
-- Indexes for table `tbl_device_mapping`
--
ALTER TABLE `tbl_device_mapping`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `device_id` (`device_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_device` (`device_id`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `tbl_exam_module`
--
ALTER TABLE `tbl_exam_module`
  ADD PRIMARY KEY (`id`),
  ADD KEY `language_id` (`language_id`);

--
-- Indexes for table `tbl_exam_module_question`
--
ALTER TABLE `tbl_exam_module_question`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category` (`exam_module_id`);

--
-- Indexes for table `tbl_exam_module_result`
--
ALTER TABLE `tbl_exam_module_result`
  ADD PRIMARY KEY (`id`),
  ADD KEY `exam_module_id` (`exam_module_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `tbl_fraud_detection`
--
ALTER TABLE `tbl_fraud_detection`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_user_type` (`user_id`,`detection_type`),
  ADD KEY `idx_severity` (`severity`),
  ADD KEY `idx_resolved` (`resolved`);

--
-- Indexes for table `tbl_fun_n_learn`
--
ALTER TABLE `tbl_fun_n_learn`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category` (`category`),
  ADD KEY `subcategory` (`subcategory`);

--
-- Indexes for table `tbl_fun_n_learn_question`
--
ALTER TABLE `tbl_fun_n_learn_question`
  ADD PRIMARY KEY (`id`),
  ADD KEY `contest_id` (`fun_n_learn_id`) USING BTREE;

--
-- Indexes for table `tbl_guess_the_word`
--
ALTER TABLE `tbl_guess_the_word`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category` (`category`),
  ADD KEY `subcategory` (`subcategory`);

--
-- Indexes for table `tbl_languages`
--
ALTER TABLE `tbl_languages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_leaderboard_daily`
--
ALTER TABLE `tbl_leaderboard_daily`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`,`date_created`);

--
-- Indexes for table `tbl_leaderboard_engagement_alltime`
--
ALTER TABLE `tbl_leaderboard_engagement_alltime`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user` (`user_id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_total_minutes` (`total_minutes` DESC);

--
-- Indexes for table `tbl_leaderboard_engagement_monthly`
--
ALTER TABLE `tbl_leaderboard_engagement_monthly`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_month` (`user_id`,`month`,`year`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_month_year` (`month`,`year`),
  ADD KEY `idx_total_minutes` (`total_minutes` DESC),
  ADD KEY `idx_ranking` (`month`,`year`,`total_minutes` DESC);

--
-- Indexes for table `tbl_leaderboard_engagement_weekly`
--
ALTER TABLE `tbl_leaderboard_engagement_weekly`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_week` (`user_id`,`week_number`,`year`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_week_year` (`week_number`,`year`),
  ADD KEY `idx_total_minutes` (`total_minutes` DESC),
  ADD KEY `idx_ranking` (`week_number`,`year`,`total_minutes` DESC);

--
-- Indexes for table `tbl_leaderboard_monthly`
--
ALTER TABLE `tbl_leaderboard_monthly`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`,`date_created`);

--
-- Indexes for table `tbl_leaderboard_weekly`
--
ALTER TABLE `tbl_leaderboard_weekly`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_week` (`user_id`,`week_number`,`year`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_week_year` (`week_number`,`year`),
  ADD KEY `idx_score` (`score` DESC),
  ADD KEY `idx_ranking` (`week_number`,`year`,`score` DESC);

--
-- Indexes for table `tbl_league`
--
ALTER TABLE `tbl_league`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_league_status` (`status`),
  ADD KEY `idx_league_dates` (`start_date`,`end_date`),
  ADD KEY `idx_league_language` (`language_id`);

--
-- Indexes for table `tbl_league_daily_quiz`
--
ALTER TABLE `tbl_league_daily_quiz`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_league_day` (`league_id`,`quiz_day`),
  ADD KEY `idx_league_quiz_date` (`quiz_date`);

--
-- Indexes for table `tbl_league_daily_quiz_questions`
--
ALTER TABLE `tbl_league_daily_quiz_questions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_daily_quiz_question` (`daily_quiz_id`,`question_id`),
  ADD KEY `idx_daily_quiz_order` (`daily_quiz_id`,`question_order`),
  ADD KEY `idx_daily_question` (`question_id`);

--
-- Indexes for table `tbl_league_leaderboard`
--
ALTER TABLE `tbl_league_leaderboard`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_league_leaderboard_user` (`league_id`,`user_id`),
  ADD KEY `idx_leaderboard_rank_sort` (`league_id`,`cumulative_best_score`,`last_updated`),
  ADD KEY `idx_leaderboard_rank` (`rank`);

--
-- Indexes for table `tbl_league_notification_log`
--
ALTER TABLE `tbl_league_notification_log`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_notif_lookup` (`league_id`,`user_id`,`notification_type`),
  ADD KEY `idx_notif_status` (`status`),
  ADD KEY `idx_notif_sent` (`sent_at`);

--
-- Indexes for table `tbl_league_prize`
--
ALTER TABLE `tbl_league_prize`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_league_prize_rank` (`league_id`,`top_winner`);

--
-- Indexes for table `tbl_league_submission`
--
ALTER TABLE `tbl_league_submission`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_submission_league_user_day` (`league_id`,`user_id`,`quiz_day`),
  ADD KEY `idx_submission_daily_quiz` (`daily_quiz_id`),
  ADD KEY `idx_submission_date` (`submission_date`);

--
-- Indexes for table `tbl_league_user`
--
ALTER TABLE `tbl_league_user`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_league_user` (`league_id`,`user_id`),
  ADD KEY `idx_league_user_status` (`status`),
  ADD KEY `idx_league_user_user` (`user_id`);

--
-- Indexes for table `tbl_level`
--
ALTER TABLE `tbl_level`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `category` (`category`),
  ADD KEY `subcategory` (`subcategory`);

--
-- Indexes for table `tbl_maths_question`
--
ALTER TABLE `tbl_maths_question`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category` (`category`),
  ADD KEY `subcategory` (`subcategory`) USING BTREE,
  ADD KEY `language_id` (`language_id`);

--
-- Indexes for table `tbl_month_week`
--
ALTER TABLE `tbl_month_week`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_multi_match`
--
ALTER TABLE `tbl_multi_match`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category` (`category`),
  ADD KEY `subcategory` (`subcategory`) USING BTREE,
  ADD KEY `language_id` (`language_id`);

--
-- Indexes for table `tbl_multi_match_level`
--
ALTER TABLE `tbl_multi_match_level`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `category` (`category`),
  ADD KEY `subcategory` (`subcategory`);

--
-- Indexes for table `tbl_multi_match_question_reports`
--
ALTER TABLE `tbl_multi_match_question_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `question_id` (`question_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `tbl_notifications`
--
ALTER TABLE `tbl_notifications`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_payment_request`
--
ALTER TABLE `tbl_payment_request`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `tbl_question`
--
ALTER TABLE `tbl_question`
  ADD PRIMARY KEY (`id`),
  ADD KEY `category` (`category`),
  ADD KEY `subcategory` (`subcategory`) USING BTREE,
  ADD KEY `language_id` (`language_id`);

--
-- Indexes for table `tbl_question_reports`
--
ALTER TABLE `tbl_question_reports`
  ADD PRIMARY KEY (`id`),
  ADD KEY `question_id` (`question_id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `tbl_quiz_categories`
--
ALTER TABLE `tbl_quiz_categories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `type` (`type`);

--
-- Indexes for table `tbl_referrals`
--
ALTER TABLE `tbl_referrals`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_referee` (`referee_id`) COMMENT 'One referral per user',
  ADD KEY `idx_referrer` (`referrer_id`),
  ADD KEY `idx_referee` (`referee_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_code` (`referral_code`),
  ADD KEY `idx_ip` (`signup_ip`),
  ADD KEY `idx_device` (`signup_device_id`),
  ADD KEY `idx_signup_date` (`signup_date`),
  ADD KEY `idx_qualified` (`status`,`qualified_date`);

--
-- Indexes for table `tbl_referral_activity`
--
ALTER TABLE `tbl_referral_activity`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_activity` (`referral_id`,`activity_date`),
  ADD KEY `idx_referral` (`referral_id`),
  ADD KEY `idx_referee_date` (`referee_id`,`activity_date`);

--
-- Indexes for table `tbl_referral_codes`
--
ALTER TABLE `tbl_referral_codes`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `referral_code` (`referral_code`),
  ADD UNIQUE KEY `unique_user_code` (`user_id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_code` (`referral_code`);

--
-- Indexes for table `tbl_referral_fraud_checks`
--
ALTER TABLE `tbl_referral_fraud_checks`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_referral` (`referral_id`),
  ADD KEY `idx_type` (`check_type`),
  ADD KEY `idx_severity` (`severity`),
  ADD KEY `idx_fraud_lookup` (`referral_id`,`resolved`,`severity`);

--
-- Indexes for table `tbl_rooms`
--
ALTER TABLE `tbl_rooms`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `category_id` (`category_id`);

--
-- Indexes for table `tbl_settings`
--
ALTER TABLE `tbl_settings`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_slider`
--
ALTER TABLE `tbl_slider`
  ADD PRIMARY KEY (`id`),
  ADD KEY `language_id` (`language_id`);

--
-- Indexes for table `tbl_sponsor_banners`
--
ALTER TABLE `tbl_sponsor_banners`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_created_by` (`created_by`),
  ADD KEY `idx_active_date` (`is_active`,`start_date`,`end_date`),
  ADD KEY `idx_priority` (`priority`);

--
-- Indexes for table `tbl_subcategory`
--
ALTER TABLE `tbl_subcategory`
  ADD PRIMARY KEY (`id`),
  ADD KEY `language_id` (`language_id`),
  ADD KEY `maincat_id` (`maincat_id`);

--
-- Indexes for table `tbl_tracker`
--
ALTER TABLE `tbl_tracker`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `tbl_upload_languages`
--
ALTER TABLE `tbl_upload_languages`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_users`
--
ALTER TABLE `tbl_users`
  ADD PRIMARY KEY (`id`),
  ADD KEY `email` (`email`,`mobile`),
  ADD KEY `firebase_id` (`firebase_id`(333)),
  ADD KEY `fcm_id` (`fcm_id`(333)),
  ADD KEY `web_fcm_id` (`web_fcm_id`(333)),
  ADD KEY `idx_country_code` (`country_code`),
  ADD KEY `idx_continent` (`continent`);

--
-- Indexes for table `tbl_users_badges`
--
ALTER TABLE `tbl_users_badges`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_users_in_app`
--
ALTER TABLE `tbl_users_in_app`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `uid` (`uid`(768)),
  ADD KEY `product_id` (`product_id`(768));

--
-- Indexes for table `tbl_users_statistics`
--
ALTER TABLE `tbl_users_statistics`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `tbl_user_audio_quiz_session`
--
ALTER TABLE `tbl_user_audio_quiz_session`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `questions` (`questions`(768));

--
-- Indexes for table `tbl_user_category`
--
ALTER TABLE `tbl_user_category`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`category_id`);

--
-- Indexes for table `tbl_user_contest_session`
--
ALTER TABLE `tbl_user_contest_session`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `questions` (`questions`(768));

--
-- Indexes for table `tbl_user_daily_quiz_session`
--
ALTER TABLE `tbl_user_daily_quiz_session`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `questions` (`questions`(768));

--
-- Indexes for table `tbl_user_engagement`
--
ALTER TABLE `tbl_user_engagement`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user_id` (`user_id`),
  ADD KEY `idx_date_created` (`date_created`),
  ADD KEY `idx_user_date` (`user_id`,`date_created`);

--
-- Indexes for table `tbl_user_fun_n_learn_session`
--
ALTER TABLE `tbl_user_fun_n_learn_session`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `questions` (`questions`(768));

--
-- Indexes for table `tbl_user_guess_the_word_session`
--
ALTER TABLE `tbl_user_guess_the_word_session`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `questions` (`questions`(768));

--
-- Indexes for table `tbl_user_maths_quiz_session`
--
ALTER TABLE `tbl_user_maths_quiz_session`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `questions` (`questions`(768));

--
-- Indexes for table `tbl_user_multi_match_session`
--
ALTER TABLE `tbl_user_multi_match_session`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `questions` (`questions`(768));

--
-- Indexes for table `tbl_user_quiz_zone_session`
--
ALTER TABLE `tbl_user_quiz_zone_session`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `questions` (`questions`(768));

--
-- Indexes for table `tbl_user_subcategory`
--
ALTER TABLE `tbl_user_subcategory`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `user_id` (`user_id`,`subcategory_id`);

--
-- Indexes for table `tbl_user_true_false_session`
--
ALTER TABLE `tbl_user_true_false_session`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `questions` (`questions`(768));

--
-- Indexes for table `tbl_web_settings`
--
ALTER TABLE `tbl_web_settings`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_ad_compliance_events`
--
ALTER TABLE `tbl_ad_compliance_events`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_ai_questions`
--
ALTER TABLE `tbl_ai_questions`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_audio_question`
--
ALTER TABLE `tbl_audio_question`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_authenticate`
--
ALTER TABLE `tbl_authenticate`
  MODIFY `auth_id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_badges`
--
ALTER TABLE `tbl_badges`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_banner_impressions`
--
ALTER TABLE `tbl_banner_impressions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_battle_questions`
--
ALTER TABLE `tbl_battle_questions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_battle_statistics`
--
ALTER TABLE `tbl_battle_statistics`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_blog_authors`
--
ALTER TABLE `tbl_blog_authors`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_blog_categories`
--
ALTER TABLE `tbl_blog_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_blog_comments`
--
ALTER TABLE `tbl_blog_comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_blog_posts`
--
ALTER TABLE `tbl_blog_posts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_blog_post_tags`
--
ALTER TABLE `tbl_blog_post_tags`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_blog_seo_analytics`
--
ALTER TABLE `tbl_blog_seo_analytics`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_bookmark`
--
ALTER TABLE `tbl_bookmark`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_cache`
--
ALTER TABLE `tbl_cache`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_category`
--
ALTER TABLE `tbl_category`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_coin_store`
--
ALTER TABLE `tbl_coin_store`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_contest`
--
ALTER TABLE `tbl_contest`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_contest_leaderboard`
--
ALTER TABLE `tbl_contest_leaderboard`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_contest_prize`
--
ALTER TABLE `tbl_contest_prize`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_contest_question`
--
ALTER TABLE `tbl_contest_question`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_country_region_mapping`
--
ALTER TABLE `tbl_country_region_mapping`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_daily_quiz`
--
ALTER TABLE `tbl_daily_quiz`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_daily_quiz_user`
--
ALTER TABLE `tbl_daily_quiz_user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_daily_streak`
--
ALTER TABLE `tbl_daily_streak`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_device_mapping`
--
ALTER TABLE `tbl_device_mapping`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_exam_module`
--
ALTER TABLE `tbl_exam_module`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_exam_module_question`
--
ALTER TABLE `tbl_exam_module_question`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_exam_module_result`
--
ALTER TABLE `tbl_exam_module_result`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_fraud_detection`
--
ALTER TABLE `tbl_fraud_detection`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_fun_n_learn`
--
ALTER TABLE `tbl_fun_n_learn`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_fun_n_learn_question`
--
ALTER TABLE `tbl_fun_n_learn_question`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_guess_the_word`
--
ALTER TABLE `tbl_guess_the_word`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_languages`
--
ALTER TABLE `tbl_languages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_leaderboard_daily`
--
ALTER TABLE `tbl_leaderboard_daily`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_leaderboard_engagement_alltime`
--
ALTER TABLE `tbl_leaderboard_engagement_alltime`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_leaderboard_engagement_monthly`
--
ALTER TABLE `tbl_leaderboard_engagement_monthly`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_leaderboard_engagement_weekly`
--
ALTER TABLE `tbl_leaderboard_engagement_weekly`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_leaderboard_monthly`
--
ALTER TABLE `tbl_leaderboard_monthly`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_leaderboard_weekly`
--
ALTER TABLE `tbl_leaderboard_weekly`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_league`
--
ALTER TABLE `tbl_league`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_league_daily_quiz`
--
ALTER TABLE `tbl_league_daily_quiz`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_league_daily_quiz_questions`
--
ALTER TABLE `tbl_league_daily_quiz_questions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_league_leaderboard`
--
ALTER TABLE `tbl_league_leaderboard`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_league_notification_log`
--
ALTER TABLE `tbl_league_notification_log`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_league_prize`
--
ALTER TABLE `tbl_league_prize`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_league_submission`
--
ALTER TABLE `tbl_league_submission`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_league_user`
--
ALTER TABLE `tbl_league_user`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_level`
--
ALTER TABLE `tbl_level`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_maths_question`
--
ALTER TABLE `tbl_maths_question`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_month_week`
--
ALTER TABLE `tbl_month_week`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_multi_match`
--
ALTER TABLE `tbl_multi_match`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_multi_match_level`
--
ALTER TABLE `tbl_multi_match_level`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_multi_match_question_reports`
--
ALTER TABLE `tbl_multi_match_question_reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_notifications`
--
ALTER TABLE `tbl_notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_payment_request`
--
ALTER TABLE `tbl_payment_request`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_question`
--
ALTER TABLE `tbl_question`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_question_reports`
--
ALTER TABLE `tbl_question_reports`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_quiz_categories`
--
ALTER TABLE `tbl_quiz_categories`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_referrals`
--
ALTER TABLE `tbl_referrals`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_referral_activity`
--
ALTER TABLE `tbl_referral_activity`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_referral_codes`
--
ALTER TABLE `tbl_referral_codes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_referral_fraud_checks`
--
ALTER TABLE `tbl_referral_fraud_checks`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_rooms`
--
ALTER TABLE `tbl_rooms`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_settings`
--
ALTER TABLE `tbl_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_slider`
--
ALTER TABLE `tbl_slider`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_sponsor_banners`
--
ALTER TABLE `tbl_sponsor_banners`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_subcategory`
--
ALTER TABLE `tbl_subcategory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_tracker`
--
ALTER TABLE `tbl_tracker`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_upload_languages`
--
ALTER TABLE `tbl_upload_languages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_users`
--
ALTER TABLE `tbl_users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_users_badges`
--
ALTER TABLE `tbl_users_badges`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_users_in_app`
--
ALTER TABLE `tbl_users_in_app`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_users_statistics`
--
ALTER TABLE `tbl_users_statistics`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_user_audio_quiz_session`
--
ALTER TABLE `tbl_user_audio_quiz_session`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_user_category`
--
ALTER TABLE `tbl_user_category`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_user_contest_session`
--
ALTER TABLE `tbl_user_contest_session`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_user_daily_quiz_session`
--
ALTER TABLE `tbl_user_daily_quiz_session`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_user_engagement`
--
ALTER TABLE `tbl_user_engagement`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_user_fun_n_learn_session`
--
ALTER TABLE `tbl_user_fun_n_learn_session`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_user_guess_the_word_session`
--
ALTER TABLE `tbl_user_guess_the_word_session`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_user_maths_quiz_session`
--
ALTER TABLE `tbl_user_maths_quiz_session`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_user_multi_match_session`
--
ALTER TABLE `tbl_user_multi_match_session`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_user_quiz_zone_session`
--
ALTER TABLE `tbl_user_quiz_zone_session`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_user_subcategory`
--
ALTER TABLE `tbl_user_subcategory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_user_true_false_session`
--
ALTER TABLE `tbl_user_true_false_session`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_web_settings`
--
ALTER TABLE `tbl_web_settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

-- --------------------------------------------------------

--
-- Structure for view `vw_referral_stats`
--
DROP TABLE IF EXISTS `vw_referral_stats`;

CREATE ALGORITHM=UNDEFINED DEFINER=`mquiz`@`localhost` SQL SECURITY DEFINER VIEW `vw_referral_stats`  AS SELECT `rc`.`user_id` AS `user_id`, `rc`.`referral_code` AS `referral_code`, `rc`.`total_referrals` AS `total_referrals`, `rc`.`successful_referrals` AS `successful_referrals`, `rc`.`total_coins_earned` AS `total_coins_earned`, count(case when `r`.`status` = 'pending' then 1 end) AS `pending_referrals`, count(case when `r`.`status` = 'qualified' then 1 end) AS `qualified_referrals`, count(case when `r`.`status` = 'rewarded' then 1 end) AS `rewarded_referrals`, count(case when `r`.`status` = 'rejected' then 1 end) AS `rejected_referrals` FROM (`tbl_referral_codes` `rc` left join `tbl_referrals` `r` on(`rc`.`user_id` = `r`.`referrer_id`)) GROUP BY `rc`.`user_id`, `rc`.`referral_code`, `rc`.`total_referrals`, `rc`.`successful_referrals`, `rc`.`total_coins_earned` ;

-- --------------------------------------------------------

--
-- Structure for view `vw_suspicious_referrals`
--
DROP TABLE IF EXISTS `vw_suspicious_referrals`;

CREATE ALGORITHM=UNDEFINED DEFINER=`mquiz`@`localhost` SQL SECURITY DEFINER VIEW `vw_suspicious_referrals`  AS SELECT `r`.`id` AS `referral_id`, `r`.`referrer_id` AS `referrer_id`, `r`.`referee_id` AS `referee_id`, `r`.`referral_code` AS `referral_code`, `r`.`signup_ip` AS `signup_ip`, `r`.`signup_device_id` AS `signup_device_id`, `r`.`status` AS `status`, count(`fc`.`id`) AS `fraud_flags`, group_concat(distinct `fc`.`check_type` separator ',') AS `fraud_types`, max(`fc`.`severity`) AS `max_severity` FROM (`tbl_referrals` `r` join `tbl_referral_fraud_checks` `fc` on(`r`.`id` = `fc`.`referral_id`)) WHERE `fc`.`resolved` = 0 GROUP BY `r`.`id`, `r`.`referrer_id`, `r`.`referee_id`, `r`.`referral_code`, `r`.`signup_ip`, `r`.`signup_device_id`, `r`.`status` HAVING count(`fc`.`id`) > 0 ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `tbl_blog_comments`
--
ALTER TABLE `tbl_blog_comments`
  ADD CONSTRAINT `fk_comment_post` FOREIGN KEY (`post_id`) REFERENCES `tbl_blog_posts` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `tbl_blog_posts`
--
ALTER TABLE `tbl_blog_posts`
  ADD CONSTRAINT `fk_blog_author` FOREIGN KEY (`author_id`) REFERENCES `tbl_blog_authors` (`id`) ON DELETE SET NULL,
  ADD CONSTRAINT `fk_blog_category` FOREIGN KEY (`category_id`) REFERENCES `tbl_blog_categories` (`id`) ON DELETE SET NULL;

--
-- Constraints for table `tbl_blog_post_tags`
--
ALTER TABLE `tbl_blog_post_tags`
  ADD CONSTRAINT `fk_post_tags` FOREIGN KEY (`post_id`) REFERENCES `tbl_blog_posts` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `tbl_blog_seo_analytics`
--
ALTER TABLE `tbl_blog_seo_analytics`
  ADD CONSTRAINT `fk_blog_seo_post` FOREIGN KEY (`post_id`) REFERENCES `tbl_blog_posts` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
