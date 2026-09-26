-- ========================================================================
-- LIVERESTRO DELIVERY APP - CUSTOMER & REAL-TIME ORDER TRACKING MIGRATION
-- Run this SQL script in your MySQL Database (e.g., via phpMyAdmin or MySQL CLI)
-- ========================================================================

USE `liverestro`;

-- 1. Create App Customers Table (Customer Accounts, Profile, Veg Preference, FCM Tokens)
CREATE TABLE IF NOT EXISTS `app_customers` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `mobile_number` VARCHAR(20) NOT NULL UNIQUE,
  `full_name` VARCHAR(150) NULL DEFAULT NULL,
  `email` VARCHAR(150) NULL DEFAULT NULL,
  `profile_image` TEXT NULL DEFAULT NULL,
  `is_veg_only` TINYINT(1) NOT NULL DEFAULT 0,
  `fcm_token` TEXT NULL DEFAULT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_cust_mobile` (`mobile_number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 2. Create App Customer Addresses Table (Saved Addresses: Home, Work, Other)
CREATE TABLE IF NOT EXISTS `app_customer_addresses` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `customer_id` INT(11) NOT NULL,
  `address_type` ENUM('home', 'work', 'other') NOT NULL DEFAULT 'home',
  `recipient_name` VARCHAR(150) NULL DEFAULT NULL,
  `recipient_phone` VARCHAR(20) NULL DEFAULT NULL,
  `complete_address` TEXT NOT NULL,
  `landmark` VARCHAR(255) NULL DEFAULT NULL,
  `latitude` DECIMAL(10,8) NOT NULL,
  `longitude` DECIMAL(11,8) NOT NULL,
  `is_default` TINYINT(1) NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `fk_customer_address` (`customer_id`),
  CONSTRAINT `fk_cust_address_customer` FOREIGN KEY (`customer_id`) REFERENCES `app_customers` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- 3. Enhance Existing `orders` Table with Customer & Online Payment Columns
-- (Checks column existence safely before adding)
SET @dbname = DATABASE();
SET @tablename = "orders";

-- Add customer_id
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @dbname
      AND TABLE_NAME = @tablename
      AND COLUMN_NAME = "customer_id"
  ) > 0,
  "SELECT 1",
  "ALTER TABLE `orders` ADD COLUMN `customer_id` INT(11) NULL AFTER `outlet_id`"
));
PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add payment_method
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @dbname
      AND TABLE_NAME = @tablename
      AND COLUMN_NAME = "payment_method"
  ) > 0,
  "SELECT 1",
  "ALTER TABLE `orders` ADD COLUMN `payment_method` VARCHAR(50) NOT NULL DEFAULT 'UPI' AFTER `payment_type`"
));
PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add payment_status
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @dbname
      AND TABLE_NAME = @tablename
      AND COLUMN_NAME = "payment_status"
  ) > 0,
  "SELECT 1",
  "ALTER TABLE `orders` ADD COLUMN `payment_status` ENUM('pending', 'paid', 'failed', 'refunded') NOT NULL DEFAULT 'paid' AFTER `payment_method`"
));
PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add delivery_tip
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @dbname
      AND TABLE_NAME = @tablename
      AND COLUMN_NAME = "delivery_tip"
  ) > 0,
  "SELECT 1",
  "ALTER TABLE `orders` ADD COLUMN `delivery_tip` DECIMAL(10,2) NOT NULL DEFAULT 0.00 AFTER `delivery_charge`"
));
PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add driver_name
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @dbname
      AND TABLE_NAME = @tablename
      AND COLUMN_NAME = "driver_name"
  ) > 0,
  "SELECT 1",
  "ALTER TABLE `orders` ADD COLUMN `driver_name` VARCHAR(150) NULL DEFAULT NULL AFTER `special_instruction`"
));
PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Add driver_phone
SET @preparedStatement = (SELECT IF(
  (
    SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = @dbname
      AND TABLE_NAME = @tablename
      AND COLUMN_NAME = "driver_phone"
  ) > 0,
  "SELECT 1",
  "ALTER TABLE `orders` ADD COLUMN `driver_phone` VARCHAR(20) NULL DEFAULT NULL AFTER `driver_name`"
));
PREPARE stmt FROM @preparedStatement;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;


-- 4. Create Order Tracking Events Table (Live Lifecycle Status Updates)
CREATE TABLE IF NOT EXISTS `order_tracking_events` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `order_id` INT(11) NOT NULL,
  `status` VARCHAR(50) NOT NULL, -- 'placed', 'preparing', 'ready', 'out_for_delivery', 'delivered', 'cancelled'
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_track_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
