-- ========================================================
-- Add image support to league records
-- ========================================================
-- Created: 2026-03-25
-- Purpose: allow admin to upload/display league cover image
-- Rollback note: to rollback, run ALTER TABLE tbl_league DROP COLUMN image;
-- ========================================================

SET @league_image_exists := (
	SELECT COUNT(*)
	FROM INFORMATION_SCHEMA.COLUMNS
	WHERE TABLE_SCHEMA = DATABASE()
	  AND TABLE_NAME = 'tbl_league'
	  AND COLUMN_NAME = 'image'
);

SET @league_image_sql := IF(
	@league_image_exists = 0,
	'ALTER TABLE `tbl_league` ADD COLUMN `image` VARCHAR(255) NULL DEFAULT NULL AFTER `description`',
	'SELECT 1'
);

PREPARE stmt FROM @league_image_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

