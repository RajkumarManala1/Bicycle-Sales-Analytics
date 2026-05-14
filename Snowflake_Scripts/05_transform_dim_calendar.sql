-- ============================================
-- Script: 05_transform_dim_calendar.sql
-- Project: Bicycle Sales & Accessories Analytics 2025
-- Description: Transforms raw DIM_DATE into cleansed DIM_CALENDAR
-- Source: RAW_DATA.DIM_DATE (3,652 rows | 19 columns)
-- Target: TRANSFORMED_DATA.DIM_CALENDAR (8 columns | filtered rows)
-- Transformations:
--   1. FILTER to CalendarYear >= 2011
--   2. RENAME columns for clarity
--   3. CREATE MonthShort (first 3 letters of month name)
--   4. SELECT only relevant columns (19 → 8)
-- ============================================

USE DATABASE SALES_ANALYTICS_2025;
USE SCHEMA TRANSFORMED_DATA;

CREATE OR REPLACE TABLE DIM_CALENDAR AS
SELECT
    DateKey                                 AS DateKey,
    FullDateAlternateKey                    AS "Date",
    EnglishDayNameOfWeek                    AS "Day",
    EnglishMonthName                        AS "Month",
    LEFT(EnglishMonthName, 3)               AS MonthShort,
    MonthNumberOfYear                       AS MonthNo,
    CalendarQuarter                         AS "Quarter",
    CalendarYear                            AS "Year"
FROM
    RAW_DATA.DIM_DATE
WHERE
    CalendarYear >= 2011
ORDER BY
    DateKey ASC;

-- Verify row count and sample data
SELECT COUNT(*) AS total_rows FROM DIM_CALENDAR;
SELECT * FROM DIM_CALENDAR LIMIT 10;

-- Verify year range
SELECT "Year", COUNT(*) AS days_count
FROM DIM_CALENDAR
GROUP BY "Year"
ORDER BY "Year";
