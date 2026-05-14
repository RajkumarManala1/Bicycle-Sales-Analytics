USE DATABASE SALES_ANALYTICS_2025;
USE SCHEMA TRANSFORMED_DATA;
USE WAREHOUSE COMPUTE_WH;

-- ============================================
-- VIEW: Sales Analytics (Fact + All Dimensions)
-- Single denormalized view for Sigma dashboards
-- ============================================
CREATE OR REPLACE VIEW VW_SALES_ANALYTICS AS
SELECT
    -- Fact Sales
    f.SALESORDERNUMBER                  AS SalesOrderNumber,
    f.SALESAMOUNT                       AS SalesAmount,
    f.ORDERDATEKEY                      AS OrderDateKey,

    -- Calendar
    c."Date"                            AS OrderDate,
    c."Day"                             AS OrderDay,
    c."Month"                           AS OrderMonth,
    c.MONTHSHORT                        AS OrderMonthShort,
    c.MONTHNO                           AS OrderMonthNo,
    c."Quarter"                         AS OrderQuarter,
    c."Year"                            AS OrderYear,

    -- Customers
    cu."Full Name"                      AS CustomerName,
    cu."First Name"                     AS CustomerFirstName,
    cu."Last Name"                      AS CustomerLastName,
    cu.GENDER                           AS CustomerGender,
    cu."Customer City"                  AS CustomerCity,

    -- Products
    p."Product Name"                    AS ProductName,
    p."Sub Category"                    AS ProductSubCategory,
    p."Product Category"                AS ProductCategory,
    p."Product Color"                   AS ProductColor,
    p."Product Size"                    AS ProductSize,
    p."Product Line"                    AS ProductLine,
    p."Product Model Name"              AS ProductModelName,
    p."Product Status"                  AS ProductStatus

FROM
    FACT_SALES f
LEFT JOIN
    DIM_CALENDAR c
    ON f.ORDERDATEKEY = c.DATEKEY
LEFT JOIN
    DIM_CUSTOMERS cu
    ON f.CUSTOMERKEY = cu.CUSTOMERKEY
LEFT JOIN
    DIM_PRODUCTS p
    ON f.PRODUCTKEY = TRY_TO_NUMBER(p.PRODUCTKEY);

-- ============================================
-- VIEW: Budget by Month
-- ============================================
CREATE OR REPLACE VIEW VW_BUDGET_BY_MONTH AS
SELECT
    b.DATE                              AS BudgetDate,
    b.BUDGET                            AS BudgetAmount
FROM
    RAW_DATA.FACT_BUDGET b;

-- ============================================
-- VALIDATION
-- ============================================

-- 1. Row count
SELECT 'VW_SALES_ANALYTICS' AS view_name, COUNT(*) AS total_rows FROM VW_SALES_ANALYTICS;

-- 2. Preview sales data with all dimensions
SELECT * FROM VW_SALES_ANALYTICS LIMIT 10;

-- 3. Verify budget data
SELECT * FROM VW_BUDGET_BY_MONTH;

-- 4. Verify joins worked (no orphan records)
SELECT
    COUNT(*) AS total_rows,
    COUNT(OrderDate) AS has_date,
    COUNT(CustomerName) AS has_customer,
    COUNT(ProductName) AS has_product
FROM VW_SALES_ANALYTICS;