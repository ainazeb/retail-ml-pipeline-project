-- =========================================================
-- SHEET 3) SAFE FORECAST + WEEKLY VIEWS + CUSTOMER CLUSTERS
-- =========================================================

USE ROLE ACCOUNTADMIN;
USE DATABASE RETAIL_PROJECT;

-- ---------------------------------------------------------
-- A) FORECAST PIPELINE
-- ---------------------------------------------------------
USE SCHEMA RAW;

CREATE STAGE IF NOT EXISTS FORECAST_STAGE;

CREATE TABLE IF NOT EXISTS RAW.WEEKLY_FORECAST_RAW (
    SalesDate STRING,
    ForecastRevenue STRING
);

LIST @FORECAST_STAGE;

COPY INTO RAW.WEEKLY_FORECAST_RAW
FROM @FORECAST_STAGE
FILE_FORMAT = (TYPE='CSV' FIELD_DELIMITER=',' SKIP_HEADER=1)
ON_ERROR='CONTINUE';

SELECT * FROM RAW.WEEKLY_FORECAST_RAW LIMIT 20;

-- ---------------------------------------------------------
-- STAGING FORECAST
-- ---------------------------------------------------------
USE SCHEMA STAGING;

CREATE TABLE IF NOT EXISTS STAGING.WEEKLY_FORECAST_STG AS
SELECT
    TRY_TO_DATE(SalesDate) AS SalesDate,
    TRY_TO_NUMBER(ForecastRevenue) AS ForecastRevenue
FROM RAW.WEEKLY_FORECAST_RAW
WHERE TRY_TO_DATE(SalesDate) IS NOT NULL
  AND TRY_TO_NUMBER(ForecastRevenue) IS NOT NULL;

-- ---------------------------------------------------------
-- MART FORECAST
-- ---------------------------------------------------------
USE SCHEMA MART;

CREATE TABLE IF NOT EXISTS MART.FCT_WEEKLY_FORECAST AS
SELECT * FROM STAGING.WEEKLY_FORECAST_STG;

CREATE OR REPLACE VIEW MART.V_WEEKLY_FORECAST AS
SELECT * FROM MART.FCT_WEEKLY_FORECAST;

CREATE OR REPLACE VIEW MART.V_WEEKLY_ACTUAL AS
SELECT
    DATE_TRUNC('WEEK', SalesDate) AS WeekStart,
    Country,
    SUM(TotalRevenue) AS ActualRevenue
FROM MART.FCT_DAILY_SALES
GROUP BY 1,2;

CREATE OR REPLACE VIEW MART.V_FORECAST_WEEKLY AS
SELECT
    DATE_TRUNC('WEEK', TO_DATE(SalesDate)) AS WeekStart,
    ForecastRevenue
FROM MART.FCT_WEEKLY_FORECAST;

CREATE OR REPLACE VIEW MART.V_REVENUE_ACTUAL_FORECAST AS
SELECT
    WeekStart,
    'Actual' AS Series,
    ActualRevenue AS Revenue
FROM MART.V_WEEKLY_ACTUAL

UNION ALL

SELECT
    WeekStart,
    'Forecast' AS Series,
    ForecastRevenue AS Revenue
FROM MART.V_FORECAST_WEEKLY
ORDER BY WeekStart;

-- ---------------------------------------------------------
-- B) CUSTOMER CLUSTERS (SAFE)
-- ---------------------------------------------------------
USE SCHEMA RAW;

CREATE TABLE IF NOT EXISTS CUSTOMER_CLUSTERS_RAW (
    CustomerID NUMBER,
    Recency NUMBER,
    Frequency NUMBER,
    Monetary NUMBER,
    Cluster NUMBER
);

COPY INTO CUSTOMER_CLUSTERS_RAW
FROM @RETAIL_CSV_STAGE/customer_rfm_clusters.csv
FILE_FORMAT=(TYPE='CSV' FIELD_DELIMITER=',' SKIP_HEADER=1)
ON_ERROR='CONTINUE';

USE SCHEMA MART;

CREATE TABLE IF NOT EXISTS DIM_CUSTOMER_CLUSTERS AS
SELECT
    CustomerID,
    Recency,
    Frequency,
    Monetary,
    Cluster
FROM RETAIL_PROJECT.RAW.CUSTOMER_CLUSTERS_RAW;

CREATE OR REPLACE VIEW MART.V_CUSTOMER_FEATURES_WITH_CLUSTER AS
SELECT
    f.*,
    c.Recency      AS RFM_Recency,
    c.Frequency    AS RFM_Frequency,
    c.Monetary     AS RFM_Monetary,
    c.Cluster      AS CustomerCluster
FROM MART.DIM_CUSTOMER_FEATURES f
LEFT JOIN MART.DIM_CUSTOMER_CLUSTERS c
    ON f.CustomerID = c.CustomerID;

SELECT * FROM MART.V_CUSTOMER_FEATURES_WITH_CLUSTER LIMIT 20;
