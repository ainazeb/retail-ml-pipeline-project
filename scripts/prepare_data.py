import pandas as pd
import numpy as np
from pathlib import Path

# -------------------------------------------------------------
# 1. Define project paths
# -------------------------------------------------------------
# BASE_DIR = main project folder (two levels above this script)
BASE_DIR = Path(__file__).resolve().parent.parent  

# Path to raw Excel file
RAW_PATH = BASE_DIR / "data_raw" / "online_retail.xlsx"

# Path where the cleaned CSV will be saved
PROCESSED_PATH = BASE_DIR / "data_processed" / "retail_clean_advanced.csv"

print("Base directory:", BASE_DIR)
print("Reading data from:", RAW_PATH)

# -------------------------------------------------------------
# 2. Load both Excel sheets
# -------------------------------------------------------------
# NOTE: Make sure sheet names match the real file exactly
df1 = pd.read_excel(RAW_PATH, sheet_name="Year 2009-2010")
df2 = pd.read_excel(RAW_PATH, sheet_name="Year 2010-2011")

print("Shape 2009-2010:", df1.shape)
print("Shape 2010-2011:", df2.shape)

# -------------------------------------------------------------
# 3. Combine both years into one DataFrame
# -------------------------------------------------------------
df = pd.concat([df1, df2], ignore_index=True)
print("Combined shape:", df.shape)

# -------------------------------------------------------------
# 4. Standardize column names
# -------------------------------------------------------------
# The dataset usually contains:
# Invoice, StockCode, Description, Quantity,
# InvoiceDate, Price, Customer ID, Country
df.columns = [
    "Invoice",
    "StockCode",
    "Description",
    "Quantity",
    "InvoiceDate",
    "Price",
    "CustomerID",
    "Country",
]

print("Columns:", df.columns.tolist())

# -------------------------------------------------------------
# 5. Drop rows with critical missing values
# -------------------------------------------------------------
# We drop rows missing Invoice, CustomerID, InvoiceDate, or StockCode
df = df.dropna(subset=["Invoice", "CustomerID", "InvoiceDate", "StockCode"])
print("After dropping critical nulls:", df.shape)

# -------------------------------------------------------------
# 6. Fix data types
# -------------------------------------------------------------
# CustomerID sometimes becomes float → convert to int
df["CustomerID"] = df["CustomerID"].astype(int)

# Convert Quantity and Price to numeric (coerce errors to NaN)
df["Quantity"] = pd.to_numeric(df["Quantity"], errors="coerce")
df["Price"] = pd.to_numeric(df["Price"], errors="coerce")

# Convert InvoiceDate to datetime
df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"], errors="coerce")

# Drop rows that became invalid after conversion
df = df.dropna(subset=["Quantity", "Price", "InvoiceDate"])
print("After fixing dtypes & dropping bad rows:", df.shape)

# -------------------------------------------------------------
# 7. Remove cancelled invoices and negative values
# -------------------------------------------------------------
# In this dataset:
# - Cancelled invoices start with 'C' (example: C12345)
# - Quantity may be negative for returns
# - Price <= 0 is invalid
cancel_mask = df["Invoice"].astype(str).str.startswith("C")
neg_qty_mask = df["Quantity"] <= 0
neg_price_mask = df["Price"] <= 0

before_cancel = df.shape[0]

# Remove rows where ANY of these conditions are true
df = df[~(cancel_mask | neg_qty_mask | neg_price_mask)]

print("Removed cancelled/negative rows:", before_cancel - df.shape[0])
print("After removing cancelled/negative:", df.shape)

# -------------------------------------------------------------
# 8. Clean text fields
# -------------------------------------------------------------
# Strip extra whitespace from Description and Country
df["Description"] = df["Description"].astype(str).str.strip()
df["Country"] = df["Country"].astype(str).str.strip()

# Convert Description to uppercase for consistency
df["Description"] = df["Description"].str.upper()

# -------------------------------------------------------------
# 9. Create new useful features
# -------------------------------------------------------------
# TotalPrice = Quantity × Price
df["TotalPrice"] = df["Quantity"] * df["Price"]

# Date-based features
df["InvoiceYear"] = df["InvoiceDate"].dt.year
df["InvoiceMonth"] = df["InvoiceDate"].dt.month
df["InvoiceDay"] = df["InvoiceDate"].dt.day
df["InvoiceHour"] = df["InvoiceDate"].dt.hour
df["InvoiceWeekday"] = df["InvoiceDate"].dt.weekday  # Monday=0

# -------------------------------------------------------------
# 10. Remove duplicate rows
# -------------------------------------------------------------
before_dups = df.shape[0]

df = df.drop_duplicates(
    subset=["Invoice", "StockCode", "CustomerID", "InvoiceDate", "Quantity", "Price"]
)

print("Removed duplicates:", before_dups - df.shape[0])
print("Final shape:", df.shape)

# -------------------------------------------------------------
# 11. Save cleaned output
# -------------------------------------------------------------
# Create folder if it does not exist
PROCESSED_PATH.parent.mkdir(parents=True, exist_ok=True)

df.to_csv(PROCESSED_PATH, index=False)
print("Clean data saved to:", PROCESSED_PATH)
