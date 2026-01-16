-- =================================================================
-- REFERRAL SYSTEM WITH ANTI-FARMING PROTECTION
-- Date: 2026-01-16
-- Purpose: Implement secure referral tracking with fraud prevention
-- =================================================================

-- ============================================================
-- Table 1: tbl_referrals
-- Purpose: Track referral relationships between users
-- ============================================================
CREATE TABLE IF NOT EXISTS `tbl_referrals` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `referrer_id` INT NOT NULL COMMENT 'User who shared the referral code',
    `referrer_uid` VARCHAR(255),
    `referee_id` INT NOT NULL COMMENT 'User who signed up using referral code',
    `referee_uid` VARCHAR(255),
    `referral_code` VARCHAR(50) NOT NULL,
    
    -- Tracking info
    `signup_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `signup_ip` VARCHAR(45) COMMENT 'IP address at signup',
    `signup_device_id` VARCHAR(255) COMMENT 'Device fingerprint',
    
    -- Activity tracking for fraud prevention
    `referee_active_days` INT DEFAULT 0 COMMENT 'Number of days referee has been active',
    `referee_quizzes_played` INT DEFAULT 0 COMMENT 'Total quizzes played by referee',
    `referee_coins_earned` INT DEFAULT 0 COMMENT 'Total coins earned by referee',
    
    -- Reward status
    `status` ENUM('pending', 'qualified', 'rewarded', 'rejected') DEFAULT 'pending',
    `qualified_date` TIMESTAMP NULL COMMENT 'Date when referee met requirements',
    `reward_date` TIMESTAMP NULL COMMENT 'Date when rewards were given',
    `rejection_reason` VARCHAR(255) COMMENT 'Why referral was rejected (fraud, duplicate, etc)',
    
    -- Rewards given
    `referrer_coins_rewarded` INT DEFAULT 0,
    `referee_coins_rewarded` INT DEFAULT 0,
    
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_referrer (referrer_id),
    INDEX idx_referee (referee_id),
    INDEX idx_status (status),
    INDEX idx_code (referral_code),
    INDEX idx_ip (signup_ip),
    INDEX idx_device (signup_device_id),
    UNIQUE KEY unique_referee (referee_id) COMMENT 'One referral per user'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table 2: tbl_referral_activity
-- Purpose: Track daily activity of referred users
-- ============================================================
CREATE TABLE IF NOT EXISTS `tbl_referral_activity` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `referral_id` INT NOT NULL COMMENT 'FK to tbl_referrals',
    `referee_id` INT NOT NULL,
    `activity_date` DATE NOT NULL,
    `quizzes_played` INT DEFAULT 0,
    `coins_earned` INT DEFAULT 0,
    `time_spent_seconds` INT DEFAULT 0,
    `is_active_day` TINYINT DEFAULT 0 COMMENT '1 if played at least 1 quiz',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    INDEX idx_referral (referral_id),
    INDEX idx_referee_date (referee_id, activity_date),
    UNIQUE KEY unique_activity (referral_id, activity_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table 3: tbl_referral_fraud_checks
-- Purpose: Track fraud detection for referrals
-- ============================================================
CREATE TABLE IF NOT EXISTS `tbl_referral_fraud_checks` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `referral_id` INT NOT NULL,
    `check_type` ENUM(
        'duplicate_ip',
        'duplicate_device',
        'same_device_multiple_accounts',
        'rapid_signups',
        'fake_activity',
        'suspicious_pattern'
    ) NOT NULL,
    `severity` ENUM('low', 'medium', 'high', 'critical') DEFAULT 'medium',
    `details` TEXT COMMENT 'JSON data with fraud details',
    `detected_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `resolved` TINYINT DEFAULT 0,
    `resolved_at` TIMESTAMP NULL,
    
    INDEX idx_referral (referral_id),
    INDEX idx_type (check_type),
    INDEX idx_severity (severity)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- Table 4: tbl_referral_codes
-- Purpose: Store unique referral codes for each user
-- ============================================================
CREATE TABLE IF NOT EXISTS `tbl_referral_codes` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL,
    `uid` VARCHAR(255),
    `referral_code` VARCHAR(50) UNIQUE NOT NULL,
    `total_referrals` INT DEFAULT 0,
    `successful_referrals` INT DEFAULT 0 COMMENT 'Referrals that qualified',
    `total_coins_earned` INT DEFAULT 0,
    `is_active` TINYINT DEFAULT 1,
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    INDEX idx_user (user_id),
    INDEX idx_code (referral_code),
    UNIQUE KEY unique_user_code (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =================================================================
-- STORED PROCEDURES FOR REFERRAL VALIDATION
-- =================================================================

DELIMITER //

-- ============================================================
-- Procedure: check_referral_eligibility
-- Purpose: Check if referee qualifies for reward
-- ============================================================
CREATE PROCEDURE IF NOT EXISTS check_referral_eligibility(
    IN p_referral_id INT,
    OUT p_eligible TINYINT,
    OUT p_reason VARCHAR(255)
)
BEGIN
    DECLARE v_active_days INT;
    DECLARE v_quizzes_played INT;
    DECLARE v_min_active_days INT;
    DECLARE v_min_quizzes INT;
    DECLARE v_fraud_count INT;
    
    -- Get requirements from settings
    SELECT message INTO v_min_active_days FROM tbl_settings WHERE type = 'referral_reward_min_active_days';
    SELECT message INTO v_min_quizzes FROM tbl_settings WHERE type = 'referral_reward_min_quizzes';
    
    -- Get referee activity
    SELECT referee_active_days, referee_quizzes_played 
    INTO v_active_days, v_quizzes_played
    FROM tbl_referrals
    WHERE id = p_referral_id;
    
    -- Check for fraud flags
    SELECT COUNT(*) INTO v_fraud_count
    FROM tbl_referral_fraud_checks
    WHERE referral_id = p_referral_id 
    AND severity IN ('high', 'critical')
    AND resolved = 0;
    
    -- Determine eligibility
    IF v_fraud_count > 0 THEN
        SET p_eligible = 0;
        SET p_reason = 'Fraud detected';
    ELSEIF v_active_days < v_min_active_days THEN
        SET p_eligible = 0;
        SET p_reason = CONCAT('Need ', v_min_active_days - v_active_days, ' more active days');
    ELSEIF v_quizzes_played < v_min_quizzes THEN
        SET p_eligible = 0;
        SET p_reason = CONCAT('Need ', v_min_quizzes - v_quizzes_played, ' more quizzes');
    ELSE
        SET p_eligible = 1;
        SET p_reason = 'Eligible for reward';
    END IF;
END//

-- ============================================================
-- Procedure: reward_referral
-- Purpose: Give coins to referrer and referee
-- ============================================================
CREATE PROCEDURE IF NOT EXISTS reward_referral(
    IN p_referral_id INT,
    OUT p_success TINYINT,
    OUT p_message VARCHAR(255)
)
BEGIN
    DECLARE v_referrer_id INT;
    DECLARE v_referee_id INT;
    DECLARE v_referrer_reward INT;
    DECLARE v_referee_reward INT;
    DECLARE v_status VARCHAR(20);
    
    -- Get referral details
    SELECT referrer_id, referee_id, status 
    INTO v_referrer_id, v_referee_id, v_status
    FROM tbl_referrals
    WHERE id = p_referral_id;
    
    -- Check if already rewarded
    IF v_status = 'rewarded' THEN
        SET p_success = 0;
        SET p_message = 'Already rewarded';
    ELSE
        -- Get bonus reward amounts from settings (not total, just bonus)
        SELECT message INTO v_referrer_reward FROM tbl_settings WHERE type = 'referral_bonus_referrer_coins';
        SELECT message INTO v_referee_reward FROM tbl_settings WHERE type = 'referral_bonus_referee_coins';
        
        -- Update referrer coins
        UPDATE tbl_users 
        SET coins = coins + v_referrer_reward 
        WHERE id = v_referrer_id;
        
        -- Update referee coins
        UPDATE tbl_users 
        SET coins = coins + v_referee_reward 
        WHERE id = v_referee_id;
        
        -- Update referral record
        UPDATE tbl_referrals
        SET status = 'rewarded',
            reward_date = NOW(),
            referrer_coins_rewarded = v_referrer_reward,
            referee_coins_rewarded = v_referee_reward
        WHERE id = p_referral_id;
        
        -- Update referral code stats
        UPDATE tbl_referral_codes
        SET successful_referrals = successful_referrals + 1,
            total_coins_earned = total_coins_earned + v_referrer_reward
        WHERE user_id = v_referrer_id;
        
        SET p_success = 1;
        SET p_message = 'Rewards distributed successfully';
    END IF;
END//

DELIMITER ;

-- =================================================================
-- VIEWS FOR ADMIN DASHBOARD
-- =================================================================

-- View: Referral Stats Summary
CREATE OR REPLACE VIEW vw_referral_stats AS
SELECT 
    rc.user_id,
    rc.referral_code,
    rc.total_referrals,
    rc.successful_referrals,
    rc.total_coins_earned,
    COUNT(CASE WHEN r.status = 'pending' THEN 1 END) as pending_referrals,
    COUNT(CASE WHEN r.status = 'qualified' THEN 1 END) as qualified_referrals,
    COUNT(CASE WHEN r.status = 'rewarded' THEN 1 END) as rewarded_referrals,
    COUNT(CASE WHEN r.status = 'rejected' THEN 1 END) as rejected_referrals
FROM tbl_referral_codes rc
LEFT JOIN tbl_referrals r ON rc.user_id = r.referrer_id
GROUP BY rc.user_id, rc.referral_code, rc.total_referrals, rc.successful_referrals, rc.total_coins_earned;

-- View: Suspicious Referrals
CREATE OR REPLACE VIEW vw_suspicious_referrals AS
SELECT 
    r.id as referral_id,
    r.referrer_id,
    r.referee_id,
    r.referral_code,
    r.signup_ip,
    r.signup_device_id,
    r.status,
    COUNT(fc.id) as fraud_flags,
    GROUP_CONCAT(DISTINCT fc.check_type) as fraud_types,
    MAX(fc.severity) as max_severity
FROM tbl_referrals r
INNER JOIN tbl_referral_fraud_checks fc ON r.id = fc.referral_id
WHERE fc.resolved = 0
GROUP BY r.id, r.referrer_id, r.referee_id, r.referral_code, r.signup_ip, r.signup_device_id, r.status
HAVING COUNT(fc.id) > 0;

-- =================================================================
-- TRIGGERS FOR AUTOMATIC FRAUD DETECTION
-- =================================================================

DELIMITER //

-- Trigger: Check for duplicate IP after referral insert
CREATE TRIGGER IF NOT EXISTS trg_check_duplicate_ip
AFTER INSERT ON tbl_referrals
FOR EACH ROW
BEGIN
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
END//

-- Trigger: Check for duplicate device
CREATE TRIGGER IF NOT EXISTS trg_check_duplicate_device
AFTER INSERT ON tbl_referrals
FOR EACH ROW
BEGIN
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
END//

DELIMITER ;

-- =================================================================
-- INDEXES FOR PERFORMANCE
-- =================================================================

-- Index for finding referrals by date range
ALTER TABLE tbl_referrals ADD INDEX idx_signup_date (signup_date);

-- Index for qualified referrals
ALTER TABLE tbl_referrals ADD INDEX idx_qualified (status, qualified_date);

-- Composite index for fraud detection queries
ALTER TABLE tbl_referral_fraud_checks ADD INDEX idx_fraud_lookup (referral_id, resolved, severity);

-- =================================================================
-- END OF REFERRAL SYSTEM MIGRATION
-- =================================================================
