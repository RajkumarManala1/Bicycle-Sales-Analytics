-- Transformations Applied:
-- 1. ROW FILTERING: Keeps only CalendarYear >= 2011 (removes 2005-2010)
-- 2. COLUMN RENAMING:
--    FullDateAlternateKey → Date
--    EnglishDayNameOfWeek → Day
--    EnglishMonthName → Month
--    MonthNumberOfYear → MonthNo
--    CalendarQuarter → Quarter
--    CalendarYear → Year
-- 3. COLUMN CREATION: MonthShort (first 3 letters of month name e.g. January → Jan)
-- 4. COLUMN SELECTION: 19 columns → 8 columns
--    Dropped: DayNumberOfWeek, SpanishDayNameOfWeek, FrenchDayNameOfWeek,
--             DayNumberOfMonth, DayNumberOfYear, WeekNumberOfYear,
--             SpanishMonthName, FrenchMonthName, CalendarSemester,
--             FiscalQuarter, FiscalYear, FiscalSemester

-- ============================================
-- SET CONTEXT
-- ============================================
USE DATABASE SALES_ANALYTICS_2025;
USE SCHEMA TRANSFORMED_DATA;
USE WAREHOUSE COMPUTE_WH;

-- ============================================
-- CREATE TRANSFORMED TABLE
-- ============================================
CREATE OR REPLACE TABLE DIM_CALENDAR AS
SELECT
    DateKey                                 AS DateKey,          -- PK (YYYYMMDD format)
    FullDateAlternateKey                    AS "Date",            -- Full date
    EnglishDayNameOfWeek                    AS "Day",             -- Day name (Monday, Tuesday, etc.)
    EnglishMonthName                        AS "Month",           -- Month name (January, February, etc.)
    LEFT(EnglishMonthName, 3)               AS MonthShort,        -- Created: First 3 letters (Jan, Feb, etc.)
    MonthNumberOfYear                       AS MonthNo,           -- Month number (1-12)
    CalendarQuarter                         AS "Quarter",         -- Quarter (1-4)
    CalendarYear                            AS "Year"             -- Year
FROM
    RAW_DATA.DIM_DATE
WHERE
    CalendarYear >= 2011
ORDER BY
    DateKey ASC;

-- ============================================
-- VALIDATION QUERIES
-- ============================================

-- 1. Verify row count
SELECT 'DIM_CALENDAR' AS table_name, COUNT(*) AS total_rows FROM DIM_CALENDAR;

-- 2. Preview sample data
SELECT * FROM DIM_CALENDAR LIMIT 10;

-- 3. Verify year range (should be 2011-2014, no 2005-2010)
SELECT "Year", COUNT(*) AS days_count
FROM DIM_CALENDAR
GROUP BY "Year"
ORDER BY "Year";

-- 4. Verify MonthShort creation
SELECT DISTINCT "Month", MonthShort, MonthNo
FROM DIM_CALENDAR
ORDER BY MonthNo;