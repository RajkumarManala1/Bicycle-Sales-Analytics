-- ============================================
-- Script: 06_transform_dim_products.sql
-- Project: Bicycle Sales & Accessories Analytics 2025
-- Description: Transforms raw DIM_PRODUCT + DIM_PRODUCT_SUBCATEGORY + DIM_PRODUCT_CATEGORY
--              into cleansed DIM_PRODUCTS
-- Source: RAW_DATA.DIM_PRODUCT (606 rows | 36 columns)
--         RAW_DATA.DIM_PRODUCT_SUBCATEGORY (37 rows | 6 columns)
--         RAW_DATA.DIM_PRODUCT_CATEGORY (4 rows | 5 columns)
-- Target: TRANSFORMED_DATA.DIM_PRODUCTS (11 columns)
-- Transformations:
--   1. JOIN with DIM_PRODUCT_SUBCATEGORY to get subcategory names
--   2. JOIN with DIM_PRODUCT_CATEGORY to get category names
--   3. HANDLE NULLs: Status NULL → 'Outdated'
--   4. DROP LargePhoto binary column and multi-language columns
--   5. SELECT only relevant columns (36 → 11)
-- ============================================

USE DATABASE SALES_ANALYTICS_2025;
USE SCHEMA TRANSFORMED_DATA;

CREATE OR REPLACE TABLE DIM_PRODUCTS AS
SELECT
    p.ProductKey                                    AS ProductKey,
    p.ProductAlternateKey                           AS ProductItemCode,
    p.EnglishProductName                            AS "Product Name",
    ps.EnglishProductSubcategoryName                AS "Sub Category",
    pc.EnglishProductCategoryName                   AS "Product Category",
    p.Color                                         AS "Product Color",
    p.Size                                          AS "Product Size",
    p.ProductLine                                   AS "Product Line",
    p.ModelName                                     AS "Product Model Name",
    p.EnglishDescription                            AS "Product Description",
    COALESCE(p.Status, 'Outdated')                  AS "Product Status"
FROM
    RAW_DATA.DIM_PRODUCT AS p
LEFT JOIN
    RAW_DATA.DIM_PRODUCT_SUBCATEGORY AS ps
    ON p.ProductSubcategoryKey = ps.ProductSubcategoryKey
LEFT JOIN
    RAW_DATA.DIM_PRODUCT_CATEGORY AS pc
    ON ps.ProductCategoryKey = pc.ProductCategoryKey
ORDER BY
    p.ProductKey ASC;

-- Verify row count and sample data
SELECT COUNT(*) AS total_rows FROM DIM_PRODUCTS;
SELECT * FROM DIM_PRODUCTS LIMIT 10;

-- Verify product category distribution
SELECT "Product Category", COUNT(*) AS product_count
FROM DIM_PRODUCTS
GROUP BY "Product Category"
ORDER BY product_count DESC;

-- Verify NULL handling for Product Status
SELECT "Product Status", COUNT(*) AS count
FROM DIM_PRODUCTS
GROUP BY "Product Status";
