# League DB Rollback Notes

Purpose: safe rollback plan for Phase 1 league schema in test/staging environments.

## Preconditions
- Pause league API traffic and admin league actions.
- Create a DB backup before rollback.
- Confirm no dependent jobs (notifications/prize distribution) are running.

## Data Loss Warning
Rollback drops all league tables and their data:
- tbl_league
- tbl_league_user
- tbl_league_daily_quiz
- tbl_league_daily_quiz_questions
- tbl_league_submission
- tbl_league_leaderboard
- tbl_league_notification_log
- tbl_league_prize

## Rollback Order
Use child-to-parent drop order to avoid dependency issues if foreign keys are added later.

```sql
DROP TABLE IF EXISTS tbl_league_prize;
DROP TABLE IF EXISTS tbl_league_notification_log;
DROP TABLE IF EXISTS tbl_league_leaderboard;
DROP TABLE IF EXISTS tbl_league_submission;
DROP TABLE IF EXISTS tbl_league_daily_quiz_questions;
DROP TABLE IF EXISTS tbl_league_daily_quiz;
DROP TABLE IF EXISTS tbl_league_user;
DROP TABLE IF EXISTS tbl_league;
```

## Post Rollback Verification
- Verify no table names remain:
  - SHOW TABLES LIKE 'tbl_league%';
- Confirm app/API behavior degrades gracefully where league features are called.
- Re-run smoke checks for contest features to ensure no side effects.

## Re-Apply Migration
To restore schema after rollback:
- Run: admin_backend/database/migrations/2026_03_19_create_league_system.sql
