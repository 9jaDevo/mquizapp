-- Migration: 2026_05_25_add_status_to_category
-- Adds a status column to tbl_category so categories can be toggled active/inactive
-- without deleting them. Mirrors the existing status column on tbl_subcategory.
-- Default: 1 (active) — all existing rows remain visible after migration.
-- Rollback section at bottom.

-- ── UP ────────────────────────────────────────────────────────────────────
ALTER TABLE `tbl_category`
  ADD COLUMN `status` TINYINT NOT NULL DEFAULT 1
  COMMENT '1 = active (visible to users), 0 = inactive (hidden)'
  AFTER `row_order`;

-- Index for the common query WHERE status = 1
CREATE INDEX `idx_category_status` ON `tbl_category` (`status`);

-- ── DOWN (rollback) ────────────────────────────────────────────────────────
-- ALTER TABLE `tbl_category` DROP INDEX `idx_category_status`;
-- ALTER TABLE `tbl_category` DROP COLUMN `status`;
