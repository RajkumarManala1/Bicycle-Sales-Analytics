-- Transformations Applied:
-- 1. COLUMN SELECTION (26 → 7 columns)
--    Kept: ProductKey, OrderDateKey, DueDateKey, ShipDateKey, CustomerKey, SalesOrderNumber, SalesAmount
--    Dropped: PromotionKey, CurrencyKey, SalesTerritoryKey (not used in dashboard analysis)
--    Dropped: SalesOrderLineNumber, RevisionNumber (order-level detail not needed)
--    Dropped: OrderQuantity, UnitPrice, ExtendedAmount (only SalesAmount needed)
--    Dropped: UnitPriceDiscountPct, DiscountAmount (discount analysis not in scope)
--    Dropped: ProductStandardCost, TotalProductCost (cost analysis not in scope)
--    Dropped: TaxAmt, Freight (tax and shipping not in scope)
--    Dropped: CarrierTrackingNumber, CustomerPONumber (operational data, not analytics)
--    Dropped: OrderDate, DueDate, ShipDate (using DateKey integers to join with DIM_CALENDAR)
--
-- 2. ROW FILTERING (60,398 → filtered rows)
--    Keeps only last 3 years of sales data (OrderDateKey year >= 2012)
--
-- 3. SORTING
--    Ordered by OrderDateKey ascending for consistent chronological processing

-- ============================================
-- SET CONTEXT
-- ============================================
USE DATABASE SALES_ANALYTICS_2025;
USE SCHEMA TRANSFORMED_DATA;
USE WAREHOUSE COMPUTE_WH;

-- ============================================
-- CREATE TRANSFORMED TABLE
-- ============================================
CREATE OR REPLACE TABLE FACT_SALES AS
SELECT
    ProductKey,                -- FK to DIM_PRODUCTS
    OrderDateKey,              -- FK to DIM_CALENDAR (join key)
    DueDateKey,                -- Due date key
    ShipDateKey,               -- Ship date key
    CustomerKey,               -- FK to DIM_CUSTOMERS
    SalesOrderNumber,          -- Unique order identifier
    SalesAmount                -- Total sales amount (primary measure)
FROM
    RAW_DATA.FACT_INTERNET_SALES
WHERE
    LEFT(CAST(OrderDateKey AS VARCHAR), 4) >= 2012
ORDER BY
    OrderDateKey ASC;

-- ============================================
-- VALIDATION QUERIES
-- ============================================

-- 1. Verify row count
SELECT 'FACT_SALES' AS table_name, COUNT(*) AS total_rows FROM FACT_SALES;

-- 2. Preview sample data
SELECT * FROM FACT_SALES LIMIT 10;

-- 3. Verify date range (should start from 2012)
SELECT
    MIN(OrderDateKey) AS earliest_order,
    MAX(OrderDateKey) AS latest_order
FROM FACT_SALES;

-- 4. Verify total sales amount
SELECT
    ROUND(SUM(SalesAmount), 2) AS total_sales_amount
FROM FACT_SALES;