-- Migration: Add Engagement Time Tracking and Location Features
-- Date: 2026-02-06
-- Description: Creates tables for user engagement tracking, leaderboards, and country/region mapping

-- =============================================
-- 1. User Engagement Session Tracking
-- =============================================

CREATE TABLE IF NOT EXISTS `tbl_user_engagement` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `session_start` datetime NOT NULL,
  `session_end` datetime DEFAULT NULL,
  `duration_seconds` int NOT NULL DEFAULT 0,
  `date_created` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_date_created` (`date_created`),
  KEY `idx_user_date` (`user_id`, `date_created`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- 2. Engagement Leaderboard Tables
-- =============================================

-- Weekly Engagement Leaderboard
CREATE TABLE IF NOT EXISTS `tbl_leaderboard_engagement_weekly` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `total_minutes` decimal(10,2) NOT NULL DEFAULT 0.00,
  `week_number` int NOT NULL,
  `year` int NOT NULL,
  `last_updated` datetime NOT NULL,
  `date_created` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_week` (`user_id`, `week_number`, `year`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_week_year` (`week_number`, `year`),
  KEY `idx_total_minutes` (`total_minutes` DESC),
  KEY `idx_ranking` (`week_number`, `year`, `total_minutes` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Monthly Engagement Leaderboard
CREATE TABLE IF NOT EXISTS `tbl_leaderboard_engagement_monthly` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `total_minutes` decimal(10,2) NOT NULL DEFAULT 0.00,
  `month` int NOT NULL,
  `year` int NOT NULL,
  `last_updated` datetime NOT NULL,
  `date_created` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_month` (`user_id`, `month`, `year`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_month_year` (`month`, `year`),
  KEY `idx_total_minutes` (`total_minutes` DESC),
  KEY `idx_ranking` (`month`, `year`, `total_minutes` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- All-Time Engagement Leaderboard
CREATE TABLE IF NOT EXISTS `tbl_leaderboard_engagement_alltime` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `total_minutes` decimal(10,2) NOT NULL DEFAULT 0.00,
  `last_updated` datetime NOT NULL,
  `date_created` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user` (`user_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_total_minutes` (`total_minutes` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- 3. Score Leaderboard - Weekly (replacing daily)
-- =============================================

CREATE TABLE IF NOT EXISTS `tbl_leaderboard_weekly` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` int NOT NULL,
  `score` int NOT NULL DEFAULT 0,
  `week_number` int NOT NULL,
  `year` int NOT NULL,
  `last_updated` datetime NOT NULL,
  `date_created` datetime NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_week` (`user_id`, `week_number`, `year`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_week_year` (`week_number`, `year`),
  KEY `idx_score` (`score` DESC),
  KEY `idx_ranking` (`week_number`, `year`, `score` DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================
-- 4. Country and Region Mapping
-- =============================================

CREATE TABLE IF NOT EXISTS `tbl_country_region_mapping` (
  `id` int NOT NULL AUTO_INCREMENT,
  `country_code` varchar(3) NOT NULL,
  `country_name` varchar(100) NOT NULL,
  `continent` varchar(50) NOT NULL,
  `region_code` varchar(10) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_country_code` (`country_code`),
  KEY `idx_continent` (`continent`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert country to continent mapping data
INSERT INTO `tbl_country_region_mapping` (`country_code`, `country_name`, `continent`, `region_code`) VALUES
-- Africa
('DZ', 'Algeria', 'Africa', 'AF'),
('AO', 'Angola', 'Africa', 'AF'),
('BJ', 'Benin', 'Africa', 'AF'),
('BW', 'Botswana', 'Africa', 'AF'),
('BF', 'Burkina Faso', 'Africa', 'AF'),
('BI', 'Burundi', 'Africa', 'AF'),
('CM', 'Cameroon', 'Africa', 'AF'),
('CV', 'Cape Verde', 'Africa', 'AF'),
('CF', 'Central African Republic', 'Africa', 'AF'),
('TD', 'Chad', 'Africa', 'AF'),
('KM', 'Comoros', 'Africa', 'AF'),
('CG', 'Congo', 'Africa', 'AF'),
('CD', 'Congo (Democratic Republic)', 'Africa', 'AF'),
('CI', 'Côte d\'Ivoire', 'Africa', 'AF'),
('DJ', 'Djibouti', 'Africa', 'AF'),
('EG', 'Egypt', 'Africa', 'AF'),
('GQ', 'Equatorial Guinea', 'Africa', 'AF'),
('ER', 'Eritrea', 'Africa', 'AF'),
('ET', 'Ethiopia', 'Africa', 'AF'),
('GA', 'Gabon', 'Africa', 'AF'),
('GM', 'Gambia', 'Africa', 'AF'),
('GH', 'Ghana', 'Africa', 'AF'),
('GN', 'Guinea', 'Africa', 'AF'),
('GW', 'Guinea-Bissau', 'Africa', 'AF'),
('KE', 'Kenya', 'Africa', 'AF'),
('LS', 'Lesotho', 'Africa', 'AF'),
('LR', 'Liberia', 'Africa', 'AF'),
('LY', 'Libya', 'Africa', 'AF'),
('MG', 'Madagascar', 'Africa', 'AF'),
('MW', 'Malawi', 'Africa', 'AF'),
('ML', 'Mali', 'Africa', 'AF'),
('MR', 'Mauritania', 'Africa', 'AF'),
('MU', 'Mauritius', 'Africa', 'AF'),
('YT', 'Mayotte', 'Africa', 'AF'),
('MA', 'Morocco', 'Africa', 'AF'),
('MZ', 'Mozambique', 'Africa', 'AF'),
('NA', 'Namibia', 'Africa', 'AF'),
('NE', 'Niger', 'Africa', 'AF'),
('NG', 'Nigeria', 'Africa', 'AF'),
('RE', 'Réunion', 'Africa', 'AF'),
('RW', 'Rwanda', 'Africa', 'AF'),
('SH', 'Saint Helena', 'Africa', 'AF'),
('ST', 'São Tomé and Príncipe', 'Africa', 'AF'),
('SN', 'Senegal', 'Africa', 'AF'),
('SC', 'Seychelles', 'Africa', 'AF'),
('SL', 'Sierra Leone', 'Africa', 'AF'),
('SO', 'Somalia', 'Africa', 'AF'),
('ZA', 'South Africa', 'Africa', 'AF'),
('SS', 'South Sudan', 'Africa', 'AF'),
('SD', 'Sudan', 'Africa', 'AF'),
('SZ', 'Swaziland', 'Africa', 'AF'),
('TZ', 'Tanzania', 'Africa', 'AF'),
('TG', 'Togo', 'Africa', 'AF'),
('TN', 'Tunisia', 'Africa', 'AF'),
('UG', 'Uganda', 'Africa', 'AF'),
('EH', 'Western Sahara', 'Africa', 'AF'),
('ZM', 'Zambia', 'Africa', 'AF'),
('ZW', 'Zimbabwe', 'Africa', 'AF'),

-- Asia
('AF', 'Afghanistan', 'Asia', 'AS'),
('AM', 'Armenia', 'Asia', 'AS'),
('AZ', 'Azerbaijan', 'Asia', 'AS'),
('BH', 'Bahrain', 'Asia', 'AS'),
('BD', 'Bangladesh', 'Asia', 'AS'),
('BT', 'Bhutan', 'Asia', 'AS'),
('BN', 'Brunei', 'Asia', 'AS'),
('KH', 'Cambodia', 'Asia', 'AS'),
('CN', 'China', 'Asia', 'AS'),
('CX', 'Christmas Island', 'Asia', 'AS'),
('CC', 'Cocos Islands', 'Asia', 'AS'),
('IO', 'British Indian Ocean Territory', 'Asia', 'AS'),
('GE', 'Georgia', 'Asia', 'AS'),
('HK', 'Hong Kong', 'Asia', 'AS'),
('IN', 'India', 'Asia', 'AS'),
('ID', 'Indonesia', 'Asia', 'AS'),
('IR', 'Iran', 'Asia', 'AS'),
('IQ', 'Iraq', 'Asia', 'AS'),
('IL', 'Israel', 'Asia', 'AS'),
('JP', 'Japan', 'Asia', 'AS'),
('JO', 'Jordan', 'Asia', 'AS'),
('KZ', 'Kazakhstan', 'Asia', 'AS'),
('KP', 'North Korea', 'Asia', 'AS'),
('KR', 'South Korea', 'Asia', 'AS'),
('KW', 'Kuwait', 'Asia', 'AS'),
('KG', 'Kyrgyzstan', 'Asia', 'AS'),
('LA', 'Laos', 'Asia', 'AS'),
('LB', 'Lebanon', 'Asia', 'AS'),
('MO', 'Macao', 'Asia', 'AS'),
('MY', 'Malaysia', 'Asia', 'AS'),
('MV', 'Maldives', 'Asia', 'AS'),
('MN', 'Mongolia', 'Asia', 'AS'),
('MM', 'Myanmar', 'Asia', 'AS'),
('NP', 'Nepal', 'Asia', 'AS'),
('OM', 'Oman', 'Asia', 'AS'),
('PK', 'Pakistan', 'Asia', 'AS'),
('PS', 'Palestine', 'Asia', 'AS'),
('PH', 'Philippines', 'Asia', 'AS'),
('QA', 'Qatar', 'Asia', 'AS'),
('SA', 'Saudi Arabia', 'Asia', 'AS'),
('SG', 'Singapore', 'Asia', 'AS'),
('LK', 'Sri Lanka', 'Asia', 'AS'),
('SY', 'Syria', 'Asia', 'AS'),
('TW', 'Taiwan', 'Asia', 'AS'),
('TJ', 'Tajikistan', 'Asia', 'AS'),
('TH', 'Thailand', 'Asia', 'AS'),
('TL', 'Timor-Leste', 'Asia', 'AS'),
('TR', 'Turkey', 'Asia', 'AS'),
('TM', 'Turkmenistan', 'Asia', 'AS'),
('AE', 'United Arab Emirates', 'Asia', 'AS'),
('UZ', 'Uzbekistan', 'Asia', 'AS'),
('VN', 'Vietnam', 'Asia', 'AS'),
('YE', 'Yemen', 'Asia', 'AS'),

-- Europe
('AX', 'Åland Islands', 'Europe', 'EU'),
('AL', 'Albania', 'Europe', 'EU'),
('AD', 'Andorra', 'Europe', 'EU'),
('AT', 'Austria', 'Europe', 'EU'),
('BY', 'Belarus', 'Europe', 'EU'),
('BE', 'Belgium', 'Europe', 'EU'),
('BA', 'Bosnia and Herzegovina', 'Europe', 'EU'),
('BG', 'Bulgaria', 'Europe', 'EU'),
('HR', 'Croatia', 'Europe', 'EU'),
('CY', 'Cyprus', 'Europe', 'EU'),
('CZ', 'Czech Republic', 'Europe', 'EU'),
('DK', 'Denmark', 'Europe', 'EU'),
('EE', 'Estonia', 'Europe', 'EU'),
('FO', 'Faroe Islands', 'Europe', 'EU'),
('FI', 'Finland', 'Europe', 'EU'),
('FR', 'France', 'Europe', 'EU'),
('DE', 'Germany', 'Europe', 'EU'),
('GI', 'Gibraltar', 'Europe', 'EU'),
('GR', 'Greece', 'Europe', 'EU'),
('GG', 'Guernsey', 'Europe', 'EU'),
('VA', 'Holy See', 'Europe', 'EU'),
('HU', 'Hungary', 'Europe', 'EU'),
('IS', 'Iceland', 'Europe', 'EU'),
('IE', 'Ireland', 'Europe', 'EU'),
('IM', 'Isle of Man', 'Europe', 'EU'),
('IT', 'Italy', 'Europe', 'EU'),
('JE', 'Jersey', 'Europe', 'EU'),
('XK', 'Kosovo', 'Europe', 'EU'),
('LV', 'Latvia', 'Europe', 'EU'),
('LI', 'Liechtenstein', 'Europe', 'EU'),
('LT', 'Lithuania', 'Europe', 'EU'),
('LU', 'Luxembourg', 'Europe', 'EU'),
('MK', 'Macedonia', 'Europe', 'EU'),
('MT', 'Malta', 'Europe', 'EU'),
('MD', 'Moldova', 'Europe', 'EU'),
('MC', 'Monaco', 'Europe', 'EU'),
('ME', 'Montenegro', 'Europe', 'EU'),
('NL', 'Netherlands', 'Europe', 'EU'),
('NO', 'Norway', 'Europe', 'EU'),
('PL', 'Poland', 'Europe', 'EU'),
('PT', 'Portugal', 'Europe', 'EU'),
('RO', 'Romania', 'Europe', 'EU'),
('RU', 'Russia', 'Europe', 'EU'),
('SM', 'San Marino', 'Europe', 'EU'),
('RS', 'Serbia', 'Europe', 'EU'),
('SK', 'Slovakia', 'Europe', 'EU'),
('SI', 'Slovenia', 'Europe', 'EU'),
('ES', 'Spain', 'Europe', 'EU'),
('SJ', 'Svalbard and Jan Mayen', 'Europe', 'EU'),
('SE', 'Sweden', 'Europe', 'EU'),
('CH', 'Switzerland', 'Europe', 'EU'),
('UA', 'Ukraine', 'Europe', 'EU'),
('GB', 'United Kingdom', 'Europe', 'EU'),

-- North America
('AI', 'Anguilla', 'North America', 'NA'),
('AG', 'Antigua and Barbuda', 'North America', 'NA'),
('AW', 'Aruba', 'North America', 'NA'),
('BS', 'Bahamas', 'North America', 'NA'),
('BB', 'Barbados', 'North America', 'NA'),
('BZ', 'Belize', 'North America', 'NA'),
('BM', 'Bermuda', 'North America', 'NA'),
('BQ', 'Bonaire', 'North America', 'NA'),
('CA', 'Canada', 'North America', 'NA'),
('KY', 'Cayman Islands', 'North America', 'NA'),
('CR', 'Costa Rica', 'North America', 'NA'),
('CU', 'Cuba', 'North America', 'NA'),
('CW', 'Curaçao', 'North America', 'NA'),
('DM', 'Dominica', 'North America', 'NA'),
('DO', 'Dominican Republic', 'North America', 'NA'),
('SV', 'El Salvador', 'North America', 'NA'),
('GL', 'Greenland', 'North America', 'NA'),
('GD', 'Grenada', 'North America', 'NA'),
('GP', 'Guadeloupe', 'North America', 'NA'),
('GT', 'Guatemala', 'North America', 'NA'),
('HT', 'Haiti', 'North America', 'NA'),
('HN', 'Honduras', 'North America', 'NA'),
('JM', 'Jamaica', 'North America', 'NA'),
('MQ', 'Martinique', 'North America', 'NA'),
('MX', 'Mexico', 'North America', 'NA'),
('MS', 'Montserrat', 'North America', 'NA'),
('NI', 'Nicaragua', 'North America', 'NA'),
('PA', 'Panama', 'North America', 'NA'),
('PM', 'Saint Pierre and Miquelon', 'North America', 'NA'),
('PR', 'Puerto Rico', 'North America', 'NA'),
('BL', 'Saint Barthélemy', 'North America', 'NA'),
('KN', 'Saint Kitts and Nevis', 'North America', 'NA'),
('LC', 'Saint Lucia', 'North America', 'NA'),
('MF', 'Saint Martin', 'North America', 'NA'),
('VC', 'Saint Vincent and the Grenadines', 'North America', 'NA'),
('SX', 'Sint Maarten', 'North America', 'NA'),
('TT', 'Trinidad and Tobago', 'North America', 'NA'),
('TC', 'Turks and Caicos Islands', 'North America', 'NA'),
('US', 'United States', 'North America', 'NA'),
('VG', 'British Virgin Islands', 'North America', 'NA'),
('VI', 'U.S. Virgin Islands', 'North America', 'NA'),

-- South America
('AR', 'Argentina', 'South America', 'SA'),
('BO', 'Bolivia', 'South America', 'SA'),
('BR', 'Brazil', 'South America', 'SA'),
('CL', 'Chile', 'South America', 'SA'),
('CO', 'Colombia', 'South America', 'SA'),
('EC', 'Ecuador', 'South America', 'SA'),
('FK', 'Falkland Islands', 'South America', 'SA'),
('GF', 'French Guiana', 'South America', 'SA'),
('GY', 'Guyana', 'South America', 'SA'),
('PY', 'Paraguay', 'South America', 'SA'),
('PE', 'Peru', 'South America', 'SA'),
('SR', 'Suriname', 'South America', 'SA'),
('UY', 'Uruguay', 'South America', 'SA'),
('VE', 'Venezuela', 'South America', 'SA'),

-- Oceania
('AS', 'American Samoa', 'Oceania', 'OC'),
('AU', 'Australia', 'Oceania', 'OC'),
('CK', 'Cook Islands', 'Oceania', 'OC'),
('FJ', 'Fiji', 'Oceania', 'OC'),
('PF', 'French Polynesia', 'Oceania', 'OC'),
('GU', 'Guam', 'Oceania', 'OC'),
('KI', 'Kiribati', 'Oceania', 'OC'),
('MH', 'Marshall Islands', 'Oceania', 'OC'),
('FM', 'Micronesia', 'Oceania', 'OC'),
('NR', 'Nauru', 'Oceania', 'OC'),
('NC', 'New Caledonia', 'Oceania', 'OC'),
('NZ', 'New Zealand', 'Oceania', 'OC'),
('NU', 'Niue', 'Oceania', 'OC'),
('NF', 'Norfolk Island', 'Oceania', 'OC'),
('MP', 'Northern Mariana Islands', 'Oceania', 'OC'),
('PW', 'Palau', 'Oceania', 'OC'),
('PG', 'Papua New Guinea', 'Oceania', 'OC'),
('PN', 'Pitcairn', 'Oceania', 'OC'),
('WS', 'Samoa', 'Oceania', 'OC'),
('SB', 'Solomon Islands', 'Oceania', 'OC'),
('TK', 'Tokelau', 'Oceania', 'OC'),
('TO', 'Tonga', 'Oceania', 'OC'),
('TV', 'Tuvalu', 'Oceania', 'OC'),
('VU', 'Vanuatu', 'Oceania', 'OC'),
('WF', 'Wallis and Futuna', 'Oceania', 'OC'),

-- Antarctica
('AQ', 'Antarctica', 'Antarctica', 'AN'),
('BV', 'Bouvet Island', 'Antarctica', 'AN'),
('TF', 'French Southern Territories', 'Antarctica', 'AN'),
('HM', 'Heard Island and McDonald Islands', 'Antarctica', 'AN'),
('GS', 'South Georgia and the South Sandwich Islands', 'Antarctica', 'AN');

-- =============================================
-- 5. Alter Users Table - Add Location Fields
-- =============================================

-- Check if columns exist before adding them
SET @dbname = DATABASE();
SET @tablename = 'tbl_users';

-- Add country_code column
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = @dbname
     AND TABLE_NAME = @tablename
     AND COLUMN_NAME = 'country_code') > 0,
  'SELECT 1',
  'ALTER TABLE tbl_users ADD COLUMN country_code VARCHAR(3) DEFAULT NULL AFTER email'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add country_name column
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = @dbname
     AND TABLE_NAME = @tablename
     AND COLUMN_NAME = 'country_name') > 0,
  'SELECT 1',
  'ALTER TABLE tbl_users ADD COLUMN country_name VARCHAR(100) DEFAULT NULL AFTER country_code'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add continent column
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = @dbname
     AND TABLE_NAME = @tablename
     AND COLUMN_NAME = 'continent') > 0,
  'SELECT 1',
  'ALTER TABLE tbl_users ADD COLUMN continent VARCHAR(50) DEFAULT NULL AFTER country_name'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add region_auto_detected column
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
   WHERE TABLE_SCHEMA = @dbname
     AND TABLE_NAME = @tablename
     AND COLUMN_NAME = 'region_auto_detected') > 0,
  'SELECT 1',
  'ALTER TABLE tbl_users ADD COLUMN region_auto_detected TINYINT(1) DEFAULT 1 AFTER continent'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- Add indexes for location fields
SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
   WHERE TABLE_SCHEMA = @dbname
     AND TABLE_NAME = @tablename
     AND INDEX_NAME = 'idx_country_code') > 0,
  'SELECT 1',
  'ALTER TABLE tbl_users ADD INDEX idx_country_code (country_code)'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

SET @preparedStatement = (SELECT IF(
  (SELECT COUNT(*) FROM INFORMATION_SCHEMA.STATISTICS
   WHERE TABLE_SCHEMA = @dbname
     AND TABLE_NAME = @tablename
     AND INDEX_NAME = 'idx_continent') > 0,
  'SELECT 1',
  'ALTER TABLE tbl_users ADD INDEX idx_continent (continent)'
));
PREPARE alterIfNotExists FROM @preparedStatement;
EXECUTE alterIfNotExists;
DEALLOCATE PREPARE alterIfNotExists;

-- =============================================
-- Migration Complete
-- =============================================
SELECT 'Migration completed successfully!' AS status;
