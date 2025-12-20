-- =========================================================
-- SHEET 2) SAFE STAGING + MART (Retail) + Customer Features + Views
-- =========================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE RETAIL_PROJECT;

-- ---------------------------------------------------------
-- 1) STAGING TABLE (SAFE)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS STAGING.ONLINE_RETAIL_STAGING AS
SELECT
    Invoice,
    StockCode,
    Description,
    Quantity,
    InvoiceDate,
    Price,
    CustomerID,
    Country,
    TotalPrice,
    InvoiceYear,
    InvoiceMonth,
    InvoiceDay,
    InvoiceHour,
    InvoiceWeekday
FROM RAW.ONLINE_RETAIL_RAW
WHERE
    Quantity > 0
    AND Price > 0
    AND CustomerID IS NOT NULL
    AND InvoiceDate IS NOT NULL;



-- ---------------------------------------------------------
-- 2) DAILY SALES FACT (SAFE)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS MART.FCT_DAILY_SALES AS
SELECT
    DATE(InvoiceDate)              AS SalesDate,
    Country,
    COUNT(DISTINCT Invoice)        AS NumInvoices,
    COUNT(DISTINCT CustomerID)     AS NumCustomers,
    SUM(Quantity)                  AS TotalQuantity,
    SUM(TotalPrice)                AS TotalRevenue
FROM STAGING.ONLINE_RETAIL_STAGING
GROUP BY SalesDate, Country;

-- ---------------------------------------------------------
-- 3) CUSTOMER FEATURES (SAFE)
-- ---------------------------------------------------------
CREATE TABLE IF NOT EXISTS MART.DIM_CUSTOMER_FEATURES AS
WITH base AS (
    SELECT
        CustomerID,
        MIN(InvoiceDate) AS FirstPurchaseDate,
        MAX(InvoiceDate) AS LastPurchaseDate,
        COUNT(DISTINCT Invoice) AS NumInvoices,
        COUNT(*) AS NumLines,
        SUM(Quantity) AS TotalQuantity,
        SUM(TotalPrice) AS TotalSpent
    FROM STAGING.ONLINE_RETAIL_STAGING
    GROUP BY CustomerID
),
with_recency AS (
    SELECT
        b.*,
        DATEDIFF('day', b.LastPurchaseDate, CURRENT_DATE()) AS RecencyDays
    FROM base b
)
SELECT
    CustomerID,
    FirstPurchaseDate,
    LastPurchaseDate,
    RecencyDays,
    NumInvoices,
    NumLines,
    TotalQuantity,
    TotalSpent
FROM with_recency;

SELECT * FROM MART.DIM_CUSTOMER_FEATURES LIMIT 20;

-- ---------------------------------------------------------
-- 4) VIEWS (safe to replace)
-- ---------------------------------------------------------
CREATE OR REPLACE VIEW MART.V_RETAIL_FOR_ANALYTICS AS
SELECT
    s.Invoice,
    s.StockCode,
    s.Description,
    s.Quantity,
    s.InvoiceDate,
    s.Price,
    s.CustomerID,
    s.Country,
    s.TotalPrice,
    s.InvoiceYear,
    s.InvoiceMonth,
    s.InvoiceDay,
    s.InvoiceHour,
    s.InvoiceWeekday
FROM STAGING.ONLINE_RETAIL_STAGING s;

CREATE OR REPLACE VIEW MART.V_CUSTOMER_FEATURES AS
SELECT *
FROM MART.DIM_CUSTOMER_FEATURES;

LIST @RETAIL_PROJECT.RAW.RETAIL_CSV_STAGE;
