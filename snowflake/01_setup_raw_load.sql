-- =========================================================
-- SHEET 1) SAFE SETUP + RAW (Retail CSV) + COPY INTO RAW
-- =========================================================

USE ROLE ACCOUNTADMIN;

-- 1) Create project database (SAFE)
CREATE DATABASE IF NOT EXISTS RETAIL_PROJECT;

-- 2) Create schemas for ELT (SAFE)
CREATE SCHEMA IF NOT EXISTS RETAIL_PROJECT.RAW;
CREATE SCHEMA IF NOT EXISTS RETAIL_PROJECT.STAGING;
CREATE SCHEMA IF NOT EXISTS RETAIL_PROJECT.MART;

USE DATABASE RETAIL_PROJECT;
USE SCHEMA RAW;

-- 3) Create stage for retail CSV files (SAFE)
CREATE STAGE IF NOT EXISTS RETAIL_CSV_STAGE;

-- 4) Create RAW table (SAFE: won't drop existing data)
CREATE TABLE IF NOT EXISTS ONLINE_RETAIL_RAW (
    Invoice         VARCHAR,
    StockCode       VARCHAR,
    Description     VARCHAR,
    Quantity        NUMBER,
    InvoiceDate     TIMESTAMP,
    Price           NUMBER(10, 4),
    CustomerID      NUMBER,
    Country         VARCHAR,
    TotalPrice      NUMBER(12, 4),
    InvoiceYear     NUMBER(4,0),
    InvoiceMonth    NUMBER(2,0),
    InvoiceDay      NUMBER(2,0),
    InvoiceHour     NUMBER(2,0),
    InvoiceWeekday  NUMBER(1,0)
);

-- 5) Check files in stage (should show your uploaded CSV)
LIST @RETAIL_CSV_STAGE;


-- TRUNCATE TABLE ONLINE_RETAIL_RAW;

COPY INTO ONLINE_RETAIL_RAW
FROM @RETAIL_CSV_STAGE
FILE_FORMAT=(TYPE='CSV' FIELD_DELIMITER=',' SKIP_HEADER=1)
ON_ERROR='CONTINUE';

SELECT * FROM ONLINE_RETAIL_RAW LIMIT 20;
