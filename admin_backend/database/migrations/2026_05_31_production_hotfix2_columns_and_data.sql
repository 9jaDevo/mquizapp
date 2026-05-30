-- =============================================================================
-- Production Hotfix #2 — 2026-05-31
-- Adds missing columns, fixes league/contest visibility, seeds booster types
-- Run with: --force to skip already-applied changes
-- =============================================================================

-- ── 1. Add correct_answers / total_answers to tbl_leaderboard_daily ──────────
ALTER TABLE `tbl_leaderboard_daily`
  ADD COLUMN `correct_answers` INT NOT NULL DEFAULT 0,
  ADD COLUMN `total_answers`   INT NOT NULL DEFAULT 0;

-- ── 2. Add price_kobo to tbl_coin_store ──────────────────────────────────────
ALTER TABLE `tbl_coin_store`
  ADD COLUMN `price_kobo` INT NOT NULL DEFAULT 0
  COMMENT 'Price in NGN kobo (minor units). 1 NGN = 100 kobo.';

-- ── 3. Fix leagues with past end_date — extend by 90 days ────────────────────
UPDATE `tbl_league`
SET `end_date` = DATE_ADD(NOW(), INTERVAL 90 DAY)
WHERE `end_date` < NOW();

-- Make sure all leagues are active
UPDATE `tbl_league`
SET `status` = 1
WHERE `status` != 1;

-- ── 4. Fix contests with past end_date — extend by 90 days ───────────────────
UPDATE `tbl_contest`
SET `end_date` = DATE_ADD(NOW(), INTERVAL 90 DAY)
WHERE `end_date` < NOW();

-- Make sure all contests are active
UPDATE `tbl_contest`
SET `status` = 1
WHERE `status` != 1;

-- ── 5. Activate all progress stages ──────────────────────────────────────────
UPDATE `tbl_progress_stages`
SET `is_active` = 1
WHERE `is_active` = 0 OR `is_active` IS NULL;

-- ── 6. Seed booster types (skip if already seeded) ───────────────────────────
INSERT INTO `tbl_booster_types` (`code`, `name`, `description`, `cost_coins`, `effect_data`, `is_active`)
SELECT * FROM (
  SELECT '50_50'      AS code, '50/50 Lifeline'  AS name, 'Removes two wrong answer options'         AS description, 30  AS cost_coins, NULL AS effect_data, 1 AS is_active
  UNION ALL
  SELECT 'time_freeze', 'Time Freeze',  'Freezes the timer for 30 seconds',             30,  NULL, 1
  UNION ALL
  SELECT 'skip',        'Skip Question','Skips the current question without penalty',   20,  NULL, 1
  UNION ALL
  SELECT 'double_coins','Double Coins', 'Doubles coins earned for correct answers',     50,  NULL, 1
) AS new_types
WHERE NOT EXISTS (SELECT 1 FROM `tbl_booster_types` LIMIT 1);
