-- ============================================
-- Script: 01_create_database_and_schemas.sql
-- Project: Bicycle Sales & Accessories Analytics 2025
-- Description: Creates the project database and schemas
-- Author: Raj Kumar Manala
-- ============================================

-- Create project database
CREATE DATABASE IF NOT EXISTS SALES_ANALYTICS_2025;

-- Switch to the database
USE DATABASE SALES_ANALYTICS_2025;

-- Bronze Layer: Raw data as-is from source
CREATE SCHEMA IF NOT EXISTS RAW_DATA;

-- Silver/Gold Layer: Cleansed, transformed, analytics-ready
CREATE SCHEMA IF NOT EXISTS TRANSFORMED_DATA;

-- Verify
SHOW SCHEMAS IN DATABASE SALES_ANALYTICS_2025;
