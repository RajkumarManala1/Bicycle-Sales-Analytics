# Bicycle Sales & Accessories Analytics 2025

An end-to-end data engineering and analytics project demonstrating a modern cloud data pipeline — from raw data extraction to interactive dashboards — using **Snowflake** for data warehousing and transformations, and **Sigma Computing** for visualization and reporting.

---

## Project Overview

This project builds a comprehensive sales analytics platform for a fictional bicycle manufacturer (Adventure Works Cycles), tracking product sales performance across **Bikes**, **Accessories**, and **Clothing** categories against monthly budgets, with drill-downs by customer demographics and geography.

The project follows a **Medallion Architecture** pattern:

- **Bronze (Raw):** Raw data extracted from AdventureWorksDW2025 and loaded into Snowflake
- **Silver/Gold (Transformed):** Cleansed, joined, and curated data modeled as a star schema in Snowflake
- **Presentation:** Interactive dashboards built in Sigma Computing connected live to Snowflake

---

## Architecture

```
┌─────────────────────┐     ┌──────────────────────────────────────────────────┐     ┌─────────────────────┐
│                     │     │              SNOWFLAKE                           │     │                     │
│   AdventureWorks    │     │                                                  │     │  SIGMA COMPUTING    │
│   DW 2025           │     │  ┌──────────────┐    ┌───────────────────────┐   │     │                     │
│   (SQL Server 2025) │────▶│  │  RAW_DATA     │───▶│  TRANSFORMED_DATA     │──▶│────▶│  Live Dashboards    │
│                     │     │  │  (Bronze)     │    │  (Silver/Gold)        │   │     │  & Reports          │
│   Docker Container  │     │  │              │    │                       │   │     │                     │
│   on macOS (ARM64)  │     │  │  8 Raw Tables │    │  4 Curated Tables     │   │     │  3 Dashboard Pages  │
│                     │     │  │              │    │  + Star Schema        │   │     │                     │
└─────────────────────┘     │  └──────────────┘    └───────────────────────┘   │     └─────────────────────┘
                            └──────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Source Database | SQL Server 2025 (Docker) | AdventureWorksDW2025 database |
| Local Environment | Docker Desktop (Apple Silicon + Rosetta 2) | Running SQL Server on macOS |
| Data Export | VS Code + MSSQL Extension | Exporting raw tables as CSV |
| Cloud Data Warehouse | Snowflake | Data storage, transformation, and modeling |
| BI / Visualization | Sigma Computing | Dashboards, reports, and interactive analytics |
| Version Control | GitHub | Project documentation and code repository |

---

## Data Source

**AdventureWorksDW2025** — Microsoft's sample data warehouse database for a fictional bicycle manufacturing company. The database was restored from the official `.bak` backup file into a SQL Server 2025 instance running in a Docker container on macOS (Apple Silicon with Rosetta 2 emulation).

Download: [AdventureWorksDW2025.bak](https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksDW2025.bak)

---

## Snowflake Database Structure

```
SALES_ANALYTICS_2025
├── RAW_DATA (Bronze Layer)
│   ├── FACT_INTERNET_SALES    (60,398 rows | 26 columns)
│   ├── DIM_CUSTOMER           (18,484 rows | 29 columns)
│   ├── DIM_DATE               (3,652 rows  | 19 columns)
│   ├── DIM_PRODUCT            (606 rows    | 36 columns)
│   ├── DIM_PRODUCT_SUBCATEGORY (37 rows    | 6 columns)
│   ├── DIM_PRODUCT_CATEGORY   (4 rows      | 5 columns)
│   ├── DIM_GEOGRAPHY          (655 rows    | 11 columns)
│   └── FACT_BUDGET            (24 rows     | 2 columns)
│
└── TRANSFORMED_DATA (Silver/Gold Layer)
    ├── FACT_SALES             (Cleansed fact table — filtered, selected columns)
    ├── DIM_CUSTOMERS          (Joined with Geography, Full Name created, Gender cleaned)
    ├── DIM_CALENDAR           (Filtered, renamed, enriched with MonthShort)
    └── DIM_PRODUCTS           (Joined with SubCategory & Category, NULLs handled)
```

---

## Raw Data Layer (Bronze)

8 raw tables extracted directly from AdventureWorksDW2025 with no transformations — preserving source fidelity.

### FACT_INTERNET_SALES (60,398 rows)
The main fact table containing individual internet sales transactions.

| Column | Type | Description |
|--------|------|-------------|
| ProductKey | INT | FK to DIM_PRODUCT |
| OrderDateKey | INT | FK to DIM_DATE |
| DueDateKey | INT | Due date key |
| ShipDateKey | INT | Ship date key |
| CustomerKey | INT | FK to DIM_CUSTOMER |
| PromotionKey | INT | FK to promotion dimension |
| CurrencyKey | INT | FK to currency dimension |
| SalesTerritoryKey | INT | FK to sales territory |
| SalesOrderNumber | VARCHAR | Unique order identifier |
| SalesOrderLineNumber | INT | Line item number |
| RevisionNumber | INT | Revision number |
| OrderQuantity | INT | Quantity ordered |
| UnitPrice | DECIMAL | Price per unit |
| ExtendedAmount | DECIMAL | Extended amount |
| UnitPriceDiscountPct | DECIMAL | Discount percentage |
| DiscountAmount | DECIMAL | Discount amount |
| ProductStandardCost | DECIMAL | Standard cost |
| TotalProductCost | DECIMAL | Total product cost |
| SalesAmount | DECIMAL | Total sales amount |
| TaxAmt | DECIMAL | Tax amount |
| Freight | DECIMAL | Freight cost |
| CarrierTrackingNumber | VARCHAR | Tracking number |
| CustomerPONumber | VARCHAR | Customer PO |
| OrderDate | DATETIME | Order date |
| DueDate | DATETIME | Due date |
| ShipDate | DATETIME | Ship date |

### DIM_CUSTOMER (18,484 rows)
Raw customer records with demographics, contact info, and geography reference.

| Key Columns | Description |
|-------------|-------------|
| CustomerKey | Unique identifier |
| GeographyKey | FK to DIM_GEOGRAPHY (for city/state/country) |
| FirstName, MiddleName, LastName | Name components (no Full Name — created in transformation) |
| Gender | Raw codes: M / F (cleaned to Male / Female in transformation) |
| EmailAddress | Customer email |
| YearlyIncome | Annual income |
| DateFirstPurchase | First purchase date |
| + 20 additional columns | Education, occupation, marital status, etc. |

### DIM_DATE (3,652 rows)
Full date dimension covering years 2005–2014 with calendar and fiscal attributes.

| Key Columns | Description |
|-------------|-------------|
| DateKey | Unique date identifier (YYYYMMDD format) |
| FullDateAlternateKey | Full date |
| EnglishDayNameOfWeek | Day name |
| EnglishMonthName | Month name |
| MonthNumberOfYear | Month number (1–12) |
| CalendarQuarter | Quarter (1–4) |
| CalendarYear | Year |
| + 12 additional columns | Spanish/French names, fiscal calendar fields |

### DIM_PRODUCT (606 rows)
Product catalog including internal components, bikes, accessories, and clothing.

| Key Columns | Description |
|-------------|-------------|
| ProductKey | Unique identifier |
| ProductAlternateKey | Product item code |
| ProductSubcategoryKey | FK to DIM_PRODUCT_SUBCATEGORY (NULL for components) |
| EnglishProductName | Product name |
| StandardCost | Manufacturing cost |
| Color, Size, ProductLine | Product attributes |
| ModelName | Model name |
| Status | Current / NULL (NULL handled as "Outdated" in transformation) |
| LargePhoto | Binary image data (dropped in transformation) |
| + 22 additional columns | Multi-language descriptions, dimensions, pricing |

### DIM_PRODUCT_SUBCATEGORY (37 rows)
Lookup table linking products to subcategories (Mountain Bikes, Road Bikes, Helmets, etc.).

### DIM_PRODUCT_CATEGORY (4 rows)
Top-level product categories: **Bikes**, **Components**, **Clothing**, **Accessories**.

### DIM_GEOGRAPHY (655 rows)
Geographic lookup with City, State, Country for customer location.

### FACT_BUDGET (24 rows)
Monthly budget targets for 2022–2023, created separately for budget vs actual analysis.

---

## Transformation Layer (Silver/Gold)

All transformations are executed in Snowflake SQL, creating clean, analytics-ready tables in the `TRANSFORMED_DATA` schema. The transformation scripts are located in the [`Snowflake_Scripts/`](Snowflake_Scripts/) directory.

### Transformations Applied

**FACT_SALES** (from FACT_INTERNET_SALES)
- Selected 7 key columns from 26 raw columns
- Filtered to last 3 years of sales data
- Removed unnecessary fields (tax, freight, tracking, PO numbers)

**DIM_CUSTOMERS** (from DIM_CUSTOMER + DIM_GEOGRAPHY)
- Joined DIM_CUSTOMER with DIM_GEOGRAPHY on GeographyKey to get Customer City
- Created Full Name column by concatenating FirstName and LastName
- Cleaned Gender codes: M → Male, F → Female
- Selected 7 key columns from 29 raw columns

**DIM_CALENDAR** (from DIM_DATE)
- Filtered to CalendarYear >= 2011
- Renamed columns for clarity (EnglishDayNameOfWeek → Day, EnglishMonthName → Month)
- Created MonthShort column (first 3 letters of month name)
- Selected 8 key columns from 19 raw columns

**DIM_PRODUCTS** (from DIM_PRODUCT + DIM_PRODUCT_SUBCATEGORY + DIM_PRODUCT_CATEGORY)
- Joined three tables to get SubCategory and Category names
- Handled NULLs: Product Status NULL → "Outdated"
- Dropped LargePhoto binary column and multi-language description columns
- Selected 11 key columns from 36 raw columns

---

## Star Schema Data Model

```
                ┌──────────────────┐          ┌──────────────────┐
                │  DIM_CUSTOMERS   │          │  DIM_CALENDAR    │
                │                  │          │                  │
                │  CustomerKey (PK)│          │  DateKey (PK)    │
                │  First Name      │          │  Date            │
                │  Last Name       │          │  Day             │
                │  Full Name       │          │  Month           │
                │  Gender          │          │  MonthShort      │
                │  DateFirstPurchase│         │  MonthNo         │
                │  Customer City   │          │  Quarter         │
                └────────┬─────────┘          │  Year            │
                         │                    └────────┬─────────┘
                         │ 1                           │ 1
                         │                             │
                         │ *                           │ *
                ┌────────┴─────────────────────────────┴─────────┐
                │                 FACT_SALES                      │
                │                                                 │
                │  ProductKey (FK)     OrderDateKey (FK)          │
                │  DueDateKey (FK)     ShipDateKey (FK)           │
                │  CustomerKey (FK)    SalesOrderNumber           │
                │  SalesAmount                                    │
                └────────┬────────────────────────────────────────┘
                         │ *
                         │
                         │ 1
                ┌────────┴─────────┐          ┌──────────────────┐
                │  DIM_PRODUCTS    │          │  FACT_BUDGET     │
                │                  │          │                  │
                │  ProductKey (PK) │          │  Date            │
                │  ProductItemCode │          │  Budget          │
                │  Product Name    │          │                  │
                │  Sub Category    │          └────────┬─────────┘
                │  Product Category│                   │ *
                │  Product Color   │                   │
                │  Product Size    │                   │ 1
                │  Product Line    │          ┌────────┴─────────┐
                │  Product Model   │          │  DIM_CALENDAR    │
                │  Product Desc    │          │  (Date ↔ Date)   │
                │  Product Status  │          └──────────────────┘
                └──────────────────┘
```

**Relationships:**
- DIM_CUSTOMERS (1) → FACT_SALES (*) on CustomerKey
- DIM_CALENDAR (1) → FACT_SALES (*) on DateKey ↔ OrderDateKey
- DIM_PRODUCTS (1) → FACT_SALES (*) on ProductKey
- DIM_CALENDAR (1) → FACT_BUDGET (*) on Date

---

## Measures

Four key measures calculated in Sigma for dashboard KPIs:

| Measure | Formula | Description |
|---------|---------|-------------|
| Sales | Sum([SalesAmount]) | Total sales revenue |
| Budget Amount | Sum([Budget]) | Total budget target |
| Sales - Budget | Sum([SalesAmount]) - Sum([Budget]) | Variance from budget |
| Sales / Budget | Sum([SalesAmount]) / Sum([Budget]) | Budget attainment percentage |

---

## Dashboards

Three interactive dashboard pages built in Sigma Computing, connected live to the Snowflake `TRANSFORMED_DATA` schema.

### Sales Overview Dashboard
Provides a high-level view of sales performance against budget targets.

![Sales Overview Dashboard](Screenshots/Sales_Overview_Dashboard.png)

**Components:**
- Sales vs Budget KPI card with variance and attainment percentage
- Sales by Product Category (donut chart — Bikes, Accessories, Clothing)
- Sales and Budget by Month (dual-line trend chart)
- Sales by Top 10 Customers (horizontal bar chart)
- Sales by Top 10 Products (horizontal bar chart)
- Sales by Customer City (geographic map)
- Interactive filters: Year, Month, Customer City, Sub Category, Product Category, Product Name

### Customer Details Dashboard
Deep dive into customer demographics, purchasing behavior, and geographic distribution.

![Customer Details Dashboard](Screenshots/Customer_Details_Dashboard.png)

**Components:**
- Sales and Budget KPI cards
- Sales by Customer City (geographic map)
- Sales by Top 10 Customers (horizontal bar chart)
- Sales and Budget by Month (dual-line trend chart)
- Customer Sales by Month (pivot table with row totals)
- Interactive filters: Year, Month, Customer City, Sub Category, Product Category, Product Name

### Product Details Dashboard
Product performance analysis by category, subcategory, and individual product.

![Product Details Dashboard](Screenshots/Product_Details_Dashboard.png)

**Components:**
- Sales and Budget KPI cards
- Sales by Customer City (geographic map)
- Sales by Top 10 Products (horizontal bar chart)
- Sales and Budget by Month (dual-line trend chart)
- Product Category Sales by Month (pivot table with row totals)
- Interactive filters: Year, Month, Customer City, Sub Category, Product Category, Product Name

---

## Project Structure

```
Bicycle-Sales-Accessories-Analytics-2025/
│
├── README.md                              # Project documentation
│
├── Raw_Datasets/                          # Bronze layer — raw CSV exports from AdventureWorksDW2025
│   ├── RAW_FactInternetSales.csv          # 60,398 rows | 26 columns
│   ├── RAW_DimCustomer.csv                # 18,484 rows | 29 columns
│   ├── RAW_DimDate.csv                    # 3,652 rows  | 19 columns
│   ├── RAW_DimProduct.csv                 # 606 rows    | 36 columns
│   ├── RAW_DimProductSubcategory.csv      # 37 rows     | 6 columns
│   ├── RAW_DimProductCategory.csv         # 4 rows      | 5 columns
│   ├── RAW_DimGeography.csv               # 655 rows    | 11 columns
│   └── FACT_Budget.csv                    # 24 rows     | 2 columns
│
├── SQL_Queries/                           # Original T-SQL cleansing queries (reference)
│   ├── Fact_Sales.sql
│   ├── Dim_Customer.sql
│   ├── DIM_Calender.sql
│   └── Dim_Products.sql
│
├── Snowflake_Scripts/                     # Snowflake SQL transformation scripts
│   ├── 01_create_database_and_schemas.sql
│   ├── 03_transform_fact_sales.sql
│   ├── 04_transform_dim_customers.sql
│   ├── 05_transform_dim_calendar.sql
│   ├── 06_transform_dim_products.sql
│   └── 07_create_views.sql
│
├── Screenshots/                           # Dashboard and schema screenshots
│   ├── Architecture_Overview.png
│   ├── Star_Schema_Model.png
│   ├── Sales_Overview_Dashboard.png
│   ├── Customer_Details_Dashboard.png
│   ├── Product_Details_Dashboard.png
│   └── Snowflake_Raw_Data.png
│
└── Sigma_Dashboards/                      # Sigma workbook exports (if applicable)
```

---

## Setup Instructions

### Prerequisites
- Docker Desktop (with Rosetta 2 for Apple Silicon)
- VS Code with MSSQL Extension
- Snowflake account (free trial: https://signup.snowflake.com)
- Sigma Computing account (free trial: https://www.sigmacomputing.com)

### Step 1: Extract Raw Data from AdventureWorksDW2025

```bash
# Pull and run SQL Server 2025 in Docker (Apple Silicon compatible)
docker pull --platform linux/amd64 mcr.microsoft.com/mssql/server:2025-latest

docker run -e "ACCEPT_EULA=Y" \
  -e "MSSQL_SA_PASSWORD=YourStrongPassword" \
  -p 1433:1433 \
  --name sqlserver \
  --platform linux/amd64 \
  -d mcr.microsoft.com/mssql/server:2025-latest

# Download and restore AdventureWorksDW2025
curl -L -o AdventureWorksDW2025.bak \
  https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksDW2025.bak

docker exec -it sqlserver mkdir -p /var/opt/mssql/backup
docker cp AdventureWorksDW2025.bak sqlserver:/var/opt/mssql/backup/

docker exec -it sqlserver /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U SA -P "YourStrongPassword" -C \
  -Q "RESTORE DATABASE AdventureWorksDW2025 FROM DISK='/var/opt/mssql/backup/AdventureWorksDW2025.bak' \
  WITH MOVE 'AdventureWorksDW' TO '/var/opt/mssql/data/AdventureWorksDW2025.mdf', \
  MOVE 'AdventureWorksDW_log' TO '/var/opt/mssql/data/AdventureWorksDW2025_log.ldf'"
```

Connect via VS Code + MSSQL extension to `localhost` and export each raw table as CSV using `SELECT * FROM <TableName>`.

### Step 2: Load Raw Data into Snowflake

```sql
CREATE DATABASE SALES_ANALYTICS_2025;
USE DATABASE SALES_ANALYTICS_2025;
CREATE SCHEMA RAW_DATA;
CREATE SCHEMA TRANSFORMED_DATA;
```

Upload all 8 CSV files into the `RAW_DATA` schema via Snowflake's "Load Data into Table" UI.

### Step 3: Run Transformation Scripts

Execute the Snowflake SQL scripts in the `Snowflake Scripts/` directory (numbered 01–07) to create the cleansed star schema tables in the `TRANSFORMED_DATA` schema.

### Step 4: Connect Sigma to Snowflake

In Sigma Computing → Administration → Connections → Add Snowflake connection with your credentials, warehouse (`COMPUTE_WH`), and database (`SALES_ANALYTICS_2025`).

### Step 5: Build Dashboards

Create a Sigma workbook with three pages — Sales Overview, Customer Details, and Product Details — connected to the `TRANSFORMED_DATA` schema tables.

---

## Key Metrics

| Metric | Value |
|--------|-------|
| Total Sales (2023) | $16,351,550 |
| Total Budget (2023) | $15,300,000 |
| Budget Attainment | 106.87% |
| Top Product Category | Bikes (93.93% of revenue) |
| Total Customers | 18,484 |
| Total Products | 606 |
| Sales Date Range | 2010 – 2014 |

---

## Tools & Technologies

![Snowflake](https://img.shields.io/badge/Snowflake-29B5E8?style=for-the-badge&logo=snowflake&logoColor=white)
![Sigma](https://img.shields.io/badge/Sigma_Computing-4A90D9?style=for-the-badge&logoColor=white)
![SQL Server](https://img.shields.io/badge/SQL_Server_2025-CC2927?style=for-the-badge&logo=microsoftsqlserver&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![VS Code](https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge&logo=visualstudiocode&logoColor=white)

---

## Author

**Raj Kumar Manala**
- LinkedIn: [linkedin.com/in/rajkumarmanala](https://linkedin.com/in/rajkumarmanala)
- Portfolio: [rajkumarmanala.com](https://rajkumarmanala.com)

---

## License

This project uses the [AdventureWorks sample database](https://learn.microsoft.com/en-us/sql/samples/adventureworks-install-configure) provided by Microsoft for educational and demonstration purposes.
