-- Migration: 2026_05_29_create_tbl_scheduled_notifications
-- Stores notifications queued for future delivery.
-- Rows are consumed by the @nestjs/schedule cron job and deleted once dispatched.

CREATE TABLE IF NOT EXISTS tbl_scheduled_notifications (
  id         INT          NOT NULL AUTO_INCREMENT,
  title      VARCHAR(128) NOT NULL,
  message    TEXT         NOT NULL,
  user_ids   LONGTEXT     NULL COMMENT 'Comma-separated user IDs; NULL means broadcast to all',
  type       VARCHAR(50)  NOT NULL DEFAULT 'general',
  type_id    INT          NOT NULL DEFAULT 0,
  image      VARCHAR(128) NOT NULL DEFAULT '',
  send_at    DATETIME     NOT NULL COMMENT 'When to dispatch this notification',
  created_at DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX idx_sched_notif_send_at (send_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
