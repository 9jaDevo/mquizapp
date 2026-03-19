# League Notification Cron Setup

This document covers Phase 6 scheduled jobs for league push notifications.

## Endpoints

- Pre-start (T-24h): /league-cron-pre-start
- Start-day: /league-cron-start-day
- Combined runner: /league-cron-job

If admin backend base URL is https://app.mquiz.uk/, full URLs are:

- https://app.mquiz.uk/league-cron-pre-start
- https://app.mquiz.uk/league-cron-start-day
- https://app.mquiz.uk/league-cron-job

## Job Behavior

- T-24h job:
  - Selects active leagues with start_date between now and next 24 hours.
  - Sends push only for users in tbl_league_user with status opt-in or active and notifications_enabled = 1.
  - Skips users already marked sent for pre-league in tbl_league_notification_log.

- Start-day job:
  - Selects active leagues where DATE(start_date) = today, start_date <= now, and end_date >= now.
  - Sends push only for users in tbl_league_user with status opt-in or active and notifications_enabled = 1.
  - Skips users already marked sent for start-day in tbl_league_notification_log.

## Logging and Retry

- Logs are stored in tbl_league_notification_log with status sent, failed, or skipped.
- Retry behavior:
  - A user is blocked only if a prior sent log exists for that league and notification_type.
  - Failed notifications are eligible for retry on subsequent job runs.

## Suggested Schedules

- T-24h: run every 60 minutes.
- Start-day: run every 15 minutes.

## User Preference API

Endpoint in Api controller:

- POST /Api/update_league_notification_preference

Body:

- league_id (required)
- notifications_enabled (required, 0 or 1)
- device_token (optional)
