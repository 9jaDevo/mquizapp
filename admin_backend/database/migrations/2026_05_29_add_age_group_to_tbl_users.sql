-- Migration: 2026_05_29_add_age_group_to_tbl_users.sql
-- Purpose : Add age_group column to tbl_users for content personalisation
--           and Apple App Store age-rating compliance.
-- Rollback: ALTER TABLE tbl_users DROP COLUMN age_group;

ALTER TABLE tbl_users
  ADD COLUMN age_group VARCHAR(20) NULL DEFAULT NULL
  COMMENT 'Content personalisation group: child | teen | adult | senior';
