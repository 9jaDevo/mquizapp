-- Migration: 2026_05_29_add_ai_generated_to_tbl_question
-- Adds ai_generated flag to tbl_question so the admin can filter
-- questions by origin (manual vs AI-approved).
-- When an AI question is approved and promoted to tbl_question, this
-- column is set to 1. All existing rows default to 0 (manually created).

-- ── UP ────────────────────────────────────────────────────────────────────
ALTER TABLE `tbl_question`
  ADD COLUMN `ai_generated` TINYINT(1) NOT NULL DEFAULT 0
    COMMENT '0 = manually created, 1 = originated from AI generation'
    AFTER `note`;

CREATE INDEX `idx_question_ai_generated` ON `tbl_question` (`ai_generated`);

-- ── DOWN (rollback) ────────────────────────────────────────────────────────
-- ALTER TABLE `tbl_question` DROP INDEX `idx_question_ai_generated`;
-- ALTER TABLE `tbl_question` DROP COLUMN `ai_generated`;
