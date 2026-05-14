-- Transformations Applied:
-- 1. JOIN: DIM_CUSTOMER + DIM_GEOGRAPHY on GeographyKey to get Customer City
-- 2. CREATE: Full Name column by concatenating FirstName + LastName
-- 3. CLEAN: Gender codes M → Male, F → Female
-- 4. COLUMN SELECTION: 29 columns → 7 columns
--    Kept: CustomerKey, First Name, Last Name, Full Name, Gender, DateFirstPurchase, Customer City
--    Dropped: GeographyKey, CustomerAlternateKey, Title, MiddleName, NameStyle,
--             BirthDate, MaritalStatus, Suffix, EmailAddress, YearlyIncome,
--             TotalChildren, NumberChildrenAtHome, EnglishEducation, SpanishEducation,
--             FrenchEducation, EnglishOccupation, SpanishOccupation, FrenchOccupation,
--             HouseOwnerFlag, NumberCarsOwned, AddressLine1, AddressLine2, Phone, CommuteDistance

-- ============================================
-- SET CONTEXT
-- ============================================
USE DATABASE SALES_ANALYTICS_2025;
USE SCHEMA TRANSFORMED_DATA;
USE WAREHOUSE COMPUTE_WH;

-- ============================================
-- CREATE TRANSFORMED TABLE
-- ============================================
CREATE OR REPLACE TABLE DIM_CUSTOMERS AS
SELECT
    c.CustomerKey                           AS CustomerKey,          -- PK
    c.FirstName                             AS "First Name",         -- Customer first name
    c.LastName                              AS "Last Name",          -- Customer last name
    CONCAT(c.FirstName, ' ', c.LastName)    AS "Full Name",          -- Created: First + Last
    CASE
        WHEN c.Gender = 'M' THEN 'Male'
        WHEN c.Gender = 'F' THEN 'Female'
        ELSE c.Gender
    END                                     AS Gender,               -- Cleaned: M → Male, F → Female
    c.DateFirstPurchase                     AS DateFirstPurchase,     -- First purchase date
    g.City                                  AS "Customer City"        -- Joined from DIM_GEOGRAPHY
FROM
    RAW_DATA.DIM_CUSTOMER AS c
LEFT JOIN
    RAW_DATA.DIM_GEOGRAPHY AS g
    ON c.GeographyKey = g.GeographyKey
ORDER BY
    c.CustomerKey ASC;

-- ============================================
-- VALIDATION QUERIES
-- ============================================

-- 1. Verify row count (should be 18,484)
SELECT 'DIM_CUSTOMERS' AS table_name, COUNT(*) AS total_rows FROM DIM_CUSTOMERS;

-- 2. Preview sample data
SELECT * FROM DIM_CUSTOMERS LIMIT 10;

-- 3. Verify gender transformation (should show Male/Female, not M/F)
SELECT Gender, COUNT(*) AS count
FROM DIM_CUSTOMERS
GROUP BY Gender
ORDER BY count DESC;

-- 4. Verify no NULL cities
SELECT COUNT(*) AS null_city_count
FROM DIM_CUSTOMERS
WHERE "Customer City" IS NULL;

-- 5. Sample Full Name verification
SELECT "First Name", "Last Name", "Full Name"
FROM DIM_CUSTOMERS
LIMIT 5;