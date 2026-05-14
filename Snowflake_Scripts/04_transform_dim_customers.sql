-- ============================================
-- Script: 04_transform_dim_customers.sql
-- Project: Bicycle Sales & Accessories Analytics 2025
-- Description: Transforms raw DIM_CUSTOMER + DIM_GEOGRAPHY into cleansed DIM_CUSTOMERS
-- Source: RAW_DATA.DIM_CUSTOMER (18,484 rows | 29 columns)
--         RAW_DATA.DIM_GEOGRAPHY (655 rows | 11 columns)
-- Target: TRANSFORMED_DATA.DIM_CUSTOMERS (7 columns)
-- Transformations:
--   1. JOIN with DIM_GEOGRAPHY to get Customer City
--   2. CREATE Full Name from FirstName + LastName
--   3. CLEAN Gender: M → Male, F → Female
--   4. SELECT only relevant columns (29 → 7)
-- ============================================

USE DATABASE SALES_ANALYTICS_2025;
USE SCHEMA TRANSFORMED_DATA;

CREATE OR REPLACE TABLE DIM_CUSTOMERS AS
SELECT
    c.CustomerKey                           AS CustomerKey,
    c.FirstName                             AS "First Name",
    c.LastName                              AS "Last Name",
    CONCAT(c.FirstName, ' ', c.LastName)    AS "Full Name",
    CASE
        WHEN c.Gender = 'M' THEN 'Male'
        WHEN c.Gender = 'F' THEN 'Female'
        ELSE c.Gender
    END                                     AS Gender,
    c.DateFirstPurchase                     AS DateFirstPurchase,
    g.City                                  AS "Customer City"
FROM
    RAW_DATA.DIM_CUSTOMER AS c
LEFT JOIN
    RAW_DATA.DIM_GEOGRAPHY AS g
    ON c.GeographyKey = g.GeographyKey
ORDER BY
    c.CustomerKey ASC;

-- Verify row count and sample data
SELECT COUNT(*) AS total_rows FROM DIM_CUSTOMERS;
SELECT * FROM DIM_CUSTOMERS LIMIT 10;

-- Verify gender transformation
SELECT Gender, COUNT(*) AS count
FROM DIM_CUSTOMERS
GROUP BY Gender;
