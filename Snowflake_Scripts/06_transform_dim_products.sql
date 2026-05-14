-- Transformations Applied:
-- 1. JOIN: DIM_PRODUCT + DIM_PRODUCT_SUBCATEGORY on ProductSubcategoryKey
-- 2. JOIN: DIM_PRODUCT_SUBCATEGORY + DIM_PRODUCT_CATEGORY on ProductCategoryKey
-- 3. NULL HANDLING: Product Status NULL → 'Outdated' using COALESCE
-- 4. COLUMN SELECTION: 35 columns → 11 columns

USE DATABASE SALES_ANALYTICS_2025;
USE SCHEMA TRANSFORMED_DATA;
USE WAREHOUSE COMPUTE_WH;

CREATE OR REPLACE TABLE DIM_PRODUCTS AS
SELECT
    p.PRODUCTKEY                                    AS ProductKey,
    p.PRODUCTALTERNATEKEY                           AS ProductItemCode,
    p.ENGLISHPRODUCTNAME                            AS "Product Name",
    ps.ENGLISHPRODUCTSUBCATEGORYNAME                AS "Sub Category",
    pc.ENGLISHPRODUCTCATEGORYNAME                   AS "Product Category",
    p.COLOR                                         AS "Product Color",
    p.SIZE                                          AS "Product Size",
    p.PRODUCTLINE                                   AS "Product Line",
    p.MODELNAME                                     AS "Product Model Name",
    p.ENGLISHDESCRIPTION                            AS "Product Description",
    CASE
        WHEN p.STATUS IS NULL OR p.STATUS = 'NULL' THEN 'Outdated'
        ELSE p.STATUS
    END                                             AS "Product Status"
FROM
    RAW_DATA.DIM_PRODUCT AS p
LEFT JOIN
    RAW_DATA.DIM_PRODUCT_SUBCATEGORY AS ps
    ON TRY_CAST(p.PRODUCTSUBCATEGORYKEY AS NUMBER) = ps.PRODUCTSUBCATEGORYKEY
LEFT JOIN
    RAW_DATA.DIM_PRODUCT_CATEGORY AS pc
    ON ps.PRODUCTCATEGORYKEY = pc.PRODUCTCATEGORYKEY
ORDER BY
    TRY_CAST(p.PRODUCTKEY AS NUMBER) ASC;
    
 
-- VALIDATION QUERIES
-- ============================================

SELECT 'DIM_PRODUCTS' AS table_name, COUNT(*) AS total_rows FROM DIM_PRODUCTS;

-- 2. Preview sample data
SELECT * FROM DIM_PRODUCTS LIMIT 10;

-- 3. Verify product category distribution
SELECT "Product Category", COUNT(*) AS product_count
FROM DIM_PRODUCTS
GROUP BY "Product Category"
ORDER BY product_count DESC;

-- 4. Verify NULL handling for Product Status
SELECT "Product Status", COUNT(*) AS count
FROM DIM_PRODUCTS
GROUP BY "Product Status";

-- 5. Verify subcategory breakdown
SELECT "Product Category", "Sub Category", COUNT(*) AS product_count
FROM DIM_PRODUCTS
WHERE "Product Category" IS NOT NULL
GROUP BY "Product Category", "Sub Category"
ORDER BY "Product Category", product_count DESC;

SELECT * FROM SALES_ANALYTICS_2025.TRANSFORMED_DATA.DIM_PRODUCTS;