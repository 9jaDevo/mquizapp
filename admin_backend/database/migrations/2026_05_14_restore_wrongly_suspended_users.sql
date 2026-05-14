-- ============================================================
-- Migration: Restore users wrongly suspended by Device_model
-- Date: 2026-05-14
-- Context: The old Device_model::register_or_update_device()
--   auto-set tbl_users.status = 'suspended' for any user on a
--   shared device, firing on every app launch. This wrongly
--   suspended legitimate users and caused them to disappear from
--   all engagement leaderboards (which filter WHERE u.status=1).
--   The root-cause code has been removed. This migration restores
--   only those users who were NOT explicitly suspended by an admin
--   via the Fraud Detection panel.
-- ============================================================

-- Step 1: Inspect before running (run SELECT first, then UPDATE).
-- SELECT COUNT(*) AS total_wrongly_suspended
-- FROM tbl_users
-- WHERE status = 'suspended'
--   AND id NOT IN (
--     SELECT DISTINCT user_id
--     FROM tbl_fraud_detection
--     WHERE action_taken = 'suspend'
--   );

-- Step 2: Restore wrongly suspended users to active status.
UPDATE tbl_users
SET status = '1'
WHERE status = 'suspended'
  AND id NOT IN (
    SELECT user_id FROM (
      SELECT DISTINCT user_id
      FROM tbl_fraud_detection
      WHERE action_taken = 'suspend'
    ) AS admin_suspended
  );

-- Step 3: Verify result.
-- SELECT status, COUNT(*) AS cnt FROM tbl_users GROUP BY status;
