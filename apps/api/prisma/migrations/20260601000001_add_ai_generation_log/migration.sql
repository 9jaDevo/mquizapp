-- CreateTable
CREATE TABLE `tbl_ai_generation_logs` (
    `id` INTEGER NOT NULL AUTO_INCREMENT,
    `admin_user_id` INTEGER NULL,
    `topic` VARCHAR(255) NOT NULL,
    `category_id` INTEGER NOT NULL DEFAULT 0,
    `difficulty` VARCHAR(20) NOT NULL DEFAULT 'medium',
    `count` INTEGER NOT NULL DEFAULT 0,
    `tokens_used` INTEGER NOT NULL DEFAULT 0,
    `prompt_tokens` INTEGER NOT NULL DEFAULT 0,
    `completion_tokens` INTEGER NOT NULL DEFAULT 0,
    `model` VARCHAR(64) NOT NULL DEFAULT '',
    `created_at` DATETIME(0) NOT NULL DEFAULT CURRENT_TIMESTAMP(0),

    INDEX `idx_ai_gen_log_created`(`created_at`),
    PRIMARY KEY (`id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
