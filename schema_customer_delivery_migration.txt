-- ========================================================================
-- LIVERESTRO DELIVERY APP - SCHEMA MIGRATION & ORDERS TABLE ROLLBACK
-- Compatible with MySQL 5.7+, MySQL 8.0+, MariaDB, phpMyAdmin
-- ========================================================================

USE `liverestro`;

-- ========================================================================
-- STEP 1: ROLL BACK ADDED COLUMNS FROM ORIGINAL `orders` TABLE
-- ========================================================================
DROP PROCEDURE IF EXISTS `RollbackOrdersTableChanges`;
DELIMITER $$
CREATE PROCEDURE `RollbackOrdersTableChanges`()
BEGIN
  -- Rollback customer_id
  IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'customer_id'
  ) THEN
    ALTER TABLE `orders` DROP COLUMN `customer_id`;
  END IF;

  -- Rollback payment_method
  IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'payment_method'
  ) THEN
    ALTER TABLE `orders` DROP COLUMN `payment_method`;
  END IF;

  -- Rollback payment_status
  IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'payment_status'
  ) THEN
    ALTER TABLE `orders` DROP COLUMN `payment_status`;
  END IF;

  -- Rollback delivery_charge
  IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'delivery_charge'
  ) THEN
    ALTER TABLE `orders` DROP COLUMN `delivery_charge`;
  END IF;

  -- Rollback delivery_tip
  IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'delivery_tip'
  ) THEN
    ALTER TABLE `orders` DROP COLUMN `delivery_tip`;
  END IF;

  -- Rollback driver_name
  IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'driver_name'
  ) THEN
    ALTER TABLE `orders` DROP COLUMN `driver_name`;
  END IF;

  -- Rollback driver_phone
  IF EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'driver_phone'
  ) THEN
    ALTER TABLE `orders` DROP COLUMN `driver_phone`;
  END IF;
END$$
DELIMITER ;

CALL `RollbackOrdersTableChanges`();
DROP PROCEDURE IF EXISTS `RollbackOrdersTableChanges`;


-- ========================================================================
-- STEP 2: CREATE `app_customers` TABLE
-- ========================================================================
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


-- ========================================================================
-- STEP 3: CREATE `app_customer_addresses` TABLE
-- ========================================================================
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


-- ========================================================================
-- STEP 4: CREATE DEDICATED `app_orders` TABLE
-- ========================================================================
CREATE TABLE IF NOT EXISTS `app_orders` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `order_number` VARCHAR(50) NOT NULL UNIQUE,
  `customer_id` INT(11) NULL,
  `restaurant_id` INT(11) NOT NULL,
  `restaurant_name` VARCHAR(150) NULL DEFAULT NULL,
  `customer_name` VARCHAR(150) NOT NULL,
  `customer_phone` VARCHAR(20) NOT NULL,
  `delivery_address` TEXT NOT NULL,
  `delivery_landmark` VARCHAR(255) NULL DEFAULT NULL,
  `delivery_lat` DECIMAL(10,8) NULL DEFAULT NULL,
  `delivery_lng` DECIMAL(11,8) NULL DEFAULT NULL,
  `total_items` INT(11) NOT NULL DEFAULT 1,
  `subtotal` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `tax_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `delivery_charge` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `delivery_tip` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `discount_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `total_amount` DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  `payment_method` VARCHAR(50) NOT NULL DEFAULT 'UPI', -- 'UPI', 'CARD', 'NET_BANKING'
  `payment_status` ENUM('pending', 'paid', 'failed', 'refunded') NOT NULL DEFAULT 'paid',
  `transaction_id` VARCHAR(100) NULL DEFAULT NULL,
  `order_status` ENUM('placed', 'confirmed', 'preparing', 'ready', 'out_for_delivery', 'delivered', 'cancelled') NOT NULL DEFAULT 'placed',
  `special_instructions` TEXT NULL DEFAULT NULL,
  `items_json` LONGTEXT NOT NULL COMMENT 'JSON array of ordered items, quantities, price, addons',
  `driver_name` VARCHAR(150) NULL DEFAULT NULL,
  `driver_phone` VARCHAR(20) NULL DEFAULT NULL,
  `driver_vehicle` VARCHAR(50) NULL DEFAULT NULL,
  `estimated_delivery_minutes` INT(11) NOT NULL DEFAULT 30,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_app_order_num` (`order_number`),
  INDEX `idx_app_order_cust` (`customer_id`),
  INDEX `idx_app_order_restro` (`restaurant_id`),
  INDEX `idx_app_order_status` (`order_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- ========================================================================
-- STEP 5: CREATE `app_order_tracking_events` TABLE
-- ========================================================================
CREATE TABLE IF NOT EXISTS `app_order_tracking_events` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `order_id` INT(11) NOT NULL,
  `status` VARCHAR(50) NOT NULL, -- 'placed', 'preparing', 'ready', 'out_for_delivery', 'delivered', 'cancelled'
  `title` VARCHAR(255) NOT NULL,
  `description` TEXT NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_track_app_order_id` (`order_id`),
  CONSTRAINT `fk_track_app_orders` FOREIGN KEY (`order_id`) REFERENCES `app_orders` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
