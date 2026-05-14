-- ============================================
-- Script: 03_transform_fact_sales.sql
-- Project: Bicycle Sales & Accessories Analytics 2025
-- Description: Transforms raw FACT_INTERNET_SALES into cleansed FACT_SALES
-- Source: RAW_DATA.FACT_INTERNET_SALES (60,398 rows | 26 columns)
-- Target: TRANSFORMED_DATA.FACT_SALES (selected columns | filtered rows)
-- ============================================

USE DATABASE SALES_ANALYTICS_2025;
USE SCHEMA TRANSFORMED_DATA;

CREATE OR REPLACE TABLE FACT_SALES AS
SELECT
    ProductKey,                -- FK to DIM_PRODUCTS
    OrderDateKey,              -- FK to DIM_CALENDAR
    DueDateKey,                -- Due date key
    ShipDateKey,               -- Ship date key
    CustomerKey,               -- FK to DIM_CUSTOMERS
    SalesOrderNumber,          -- Unique order identifier
    SalesAmount                -- Total sales amount
FROM
    RAW_DATA.FACT_INTERNET_SALES
WHERE
    LEFT(CAST(OrderDateKey AS VARCHAR), 4) >= YEAR(CURRENT_DATE()) - 3
ORDER BY
    OrderDateKey ASC;

-- Verify row count and sample data
SELECT COUNT(*) AS total_rows FROM FACT_SALES;
SELECT * FROM FACT_SALES LIMIT 10;
