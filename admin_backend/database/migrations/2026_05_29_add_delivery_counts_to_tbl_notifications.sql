-- Migration: 2026_05_29_add_delivery_counts_to_tbl_notifications
-- Adds delivered_count and failed_count columns to tbl_notifications
-- so FCM multicast results are persisted alongside each sent notification.

ALTER TABLE tbl_notifications
  ADD COLUMN delivered_count INT NOT NULL DEFAULT 0 AFTER date_sent,
  ADD COLUMN failed_count    INT NOT NULL DEFAULT 0 AFTER delivered_count;
