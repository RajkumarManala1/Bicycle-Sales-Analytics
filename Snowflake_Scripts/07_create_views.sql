-- ============================================
-- Script: 07_create_views.sql
-- Project: Bicycle Sales & Accessories Analytics 2025
-- Description: Creates analytics-ready views joining fact and dimension tables
--              These views serve as the data source for Sigma dashboards
-- ============================================

USE DATABASE SALES_ANALYTICS_2025;
USE SCHEMA TRANSFORMED_DATA;

-- ============================================
-- View: Sales Overview (Fact + All Dimensions)
-- Purpose: Single denormalized view for Sigma dashboards
-- ============================================

CREATE OR REPLACE VIEW VW_SALES_ANALYTICS AS
SELECT
    -- Fact Sales columns
    f.SalesOrderNumber,
    f.SalesAmount,
    f.OrderDateKey,

    -- Calendar columns
    c."Date"            AS OrderDate,
    c."Day"             AS OrderDay,
    c."Month"           AS OrderMonth,
    c.MonthShort        AS OrderMonthShort,
    c.MonthNo           AS OrderMonthNo,
    c."Quarter"         AS OrderQuarter,
    c."Year"            AS OrderYear,

    -- Customer columns
    cu."Full Name"      AS CustomerName,
    cu."First Name"     AS CustomerFirstName,
    cu."Last Name"      AS CustomerLastName,
    cu.Gender           AS CustomerGender,
    cu."Customer City"  AS CustomerCity,

    -- Product columns
    p."Product Name"        AS ProductName,
    p."Sub Category"        AS ProductSubCategory,
    p."Product Category"    AS ProductCategory,
    p."Product Color"       AS ProductColor,
    p."Product Size"        AS ProductSize,
    p."Product Line"        AS ProductLine,
    p."Product Model Name"  AS ProductModelName,
    p."Product Status"      AS ProductStatus

FROM
    FACT_SALES f
LEFT JOIN DIM_CALENDAR c    ON f.OrderDateKey = c.DateKey
LEFT JOIN DIM_CUSTOMERS cu  ON f.CustomerKey = cu.CustomerKey
LEFT JOIN DIM_PRODUCTS p    ON f.ProductKey = p.ProductKey;

-- ============================================
-- View: Budget by Month
-- Purpose: Monthly budget targets for comparison
-- ============================================

CREATE OR REPLACE VIEW VW_BUDGET_BY_MONTH AS
SELECT
    b.Date          AS BudgetDate,
    b.Budget        AS BudgetAmount
FROM
    RAW_DATA.FACT_BUDGET b;

-- Verify views
SELECT COUNT(*) AS total_rows FROM VW_SALES_ANALYTICS;
SELECT * FROM VW_SALES_ANALYTICS LIMIT 10;

SELECT * FROM VW_BUDGET_BY_MONTH;
