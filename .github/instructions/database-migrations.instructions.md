---
description: "Use when creating new SQL migration files, modifying database schema, adding tables or columns to the mQuiz MySQL database. Covers naming conventions, rollback safety, backward compatibility, and index requirements."
applyTo: "**/admin_backend/database/migrations/*.sql"
---

# Database Migration Rules

## Non-Destructive Strategy

All migrations during Phase 1–3 must be additive only. The PHP backend and Node.js backend run against the same database concurrently.

- **Add** columns, tables, indexes freely.
- **Never DROP** a column or table that the PHP backend still reads from.
- **Never RENAME** a column — add the new name alongside the old, backfill data, then deprecate the old column in a later migration after PHP is decommissioned.

## File Naming Convention

```
YYYY_MM_DD_description_of_change.sql
```

Example: `2026_06_01_add_user_lives_table.sql`

## Migration File Header

Every migration must start with this header:

```sql
-- Migration: add_user_lives_table
-- Date: YYYY-MM-DD
-- Description: Creates tbl_user_lives for the lives/attempts system (Phase 4)
-- Rollback: DROP TABLE IF EXISTS `tbl_user_lives`;
-- Backward Compatible: YES — new table, no existing tables modified
-- PHP Backend Impact: NONE — PHP backend does not reference this table
```

## Table Naming

All tables use the `tbl_` prefix:

```sql
CREATE TABLE `tbl_user_lives` (...)
```

## Required Columns

Every new table must include:

```sql
`id` int(11) NOT NULL AUTO_INCREMENT,
`created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
PRIMARY KEY (`id`)
```

Tables with updatable rows must include:

```sql
`updated_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
```

## Required Indexes

Add indexes for:
- All foreign key columns (`user_id`, `league_id`, etc.)
- Leaderboard and ranking queries: `(score DESC)`, `(league_id, score DESC)`
- Date-based lookups: `(user_id, date)` for daily submission tables
- Status-filtered queries on large tables: `(status)`

```sql
KEY `idx_user_id` (`user_id`),
KEY `idx_league_score` (`league_id`, `cumulative_best_score` DESC)
```

## Character Set

All new tables use:

```sql
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
```

Do not create new tables with `latin1` or `MyISAM` — those are legacy from the original CodeCanyon schema.

## Foreign Keys

Avoid hard FK constraints during Phase 1–3 (the dual-running period creates complexity). Use logical foreign keys (indexed columns with `COMMENT 'FK: tbl_users.id'`) instead of `FOREIGN KEY ... REFERENCES`.

This is intentional — add actual FK constraints after PHP is fully decommissioned.

## Backward Compatibility

Before adding a `NOT NULL` column to an existing table:
1. Add it as `NULL` or with a `DEFAULT` value.
2. Backfill existing rows.
3. Only then tighten to `NOT NULL` if needed.

```sql
-- Step 1 (safe to deploy immediately)
ALTER TABLE `tbl_users` ADD COLUMN `age_group` varchar(20) NULL DEFAULT NULL;

-- Step 2 (in same migration or next)
UPDATE `tbl_users` SET `age_group` = 'adults' WHERE `age_group` IS NULL;
```

## Rollback Notes

Any migration that creates a critical table (league, payment, school) must have a tested rollback section:

```sql
-- ROLLBACK SECTION (run manually if migration needs to be reversed):
-- DROP TABLE IF EXISTS `tbl_user_lives`;
-- ALTER TABLE `tbl_users` DROP COLUMN IF EXISTS `age_group`;
```
