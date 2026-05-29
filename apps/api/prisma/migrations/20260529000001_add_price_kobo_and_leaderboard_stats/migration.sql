-- Add price_kobo to coin store so backend controls payment amount (security fix)
ALTER TABLE `tbl_coin_store`
  ADD COLUMN `price_kobo` INT NOT NULL DEFAULT 0
  COMMENT 'Price in NGN kobo (minor units). 1 NGN = 100 kobo.';

-- Add correct/total answer counts to daily leaderboard for accuracy tracking
ALTER TABLE `tbl_leaderboard_daily`
  ADD COLUMN `correct_answers` INT NOT NULL DEFAULT 0,
  ADD COLUMN `total_answers`   INT NOT NULL DEFAULT 0;
