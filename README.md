# Retail Data Engineering + ML + BI Project (Snowflake • FastAPI • Docker • GitHub Actions • Power BI)

End-to-end portfolio project built on the **Online Retail II** dataset (UCI).  
It demonstrates a complete workflow from data preparation → ELT in Snowflake → ML modeling (RFM clustering + forecasting) → BI dashboards → API productization → Docker + CI/CD.

---

## ✅ What I Built

### 1) Data Preparation (Python)
- Loaded the Online Retail II Excel (2009–2010 + 2010–2011)
- Cleaned data (missing values, types, duplicates)
- Removed cancelled invoices (Invoice starts with "C") and negative/invalid values
- Created useful features (TotalPrice, time features)
- Exported a clean CSV for ingestion

Script:
- `scripts/prepare_data.py`

---

### 2) ELT in Snowflake (RAW → STAGING → MART)
**RAW**
- Stage + COPY INTO raw table

**STAGING**
- Filtered invalid rows (Quantity/Price > 0, non-null CustomerID, etc.)

**MART**
- Fact table for analytics: `FCT_DAILY_SALES`
- Customer feature table for ML/BI: `DIM_CUSTOMER_FEATURES`
- Views for Power BI and API consumption

SQL scripts:
- `sql/01_raw_stage_load.sql`
- `sql/02_staging_transform.sql`
- `sql/03_mart_views.sql`

---

### 3) Machine Learning (Notebook)
Notebook:
- `notebooks/retail_ml.ipynb`

Implemented:
- **RFM feature engineering**
- **KMeans clustering** for customer segmentation
- **Time-series forecasting** (SARIMA) for future revenue

Forecast output is loaded back into Snowflake and exposed via:
- `MART.V_REVENUE_ACTUAL_FORECAST`

---

### 4) Power BI Dashboard
Built a dashboard on Snowflake views:
- Sales overview (Total Revenue, daily/weekly trends, country split)
- Customer analytics using RFM features
- Actual vs Forecast analysis

Docs/Screenshots:
- `docs/powerbi/`

---

### 5) FastAPI + Docker + CI/CD
API:
- `app/main.py` exposes endpoints that query Snowflake views and return JSON

Docker:
- `Dockerfile` builds the API container

CI/CD:
- GitHub Actions workflows in `.github/workflows/`
- CI checks build steps
- CD builds & pushes Docker image to Docker Hub on push to `main`

---

## 🧱 Project Structure

retail-ml-pipeline-project/
│
├── app/ # Core application logic
│ ├── main.py # Entry point
│ ├── db.py # Database connections
│ ├── schemas.py # Data schemas
│ ├── data_raw/ # Raw data
│ ├── data_processed/ # Processed datasets
│ ├── data_features/ # Feature-engineered data
│ └── models/ # Trained ML models
│
├── notebooks/ # Exploration & experimentation
│ └── retail_ml.ipynb
│
├── scripts/ # Data preparation scripts
│ └── prepare_data.py
│
├── snowflake/ # SQL pipeline (warehouse layer)
│ ├── 01_setup_raw_load.sql
│ ├── 02_staging_mart_views.sql
│ └── 03_forecast_clusters_reporting.sql
│
├── PowerBI_dashboard/ # BI dashboards & screenshots
│ ├── retail.dashboard.pbix
│ ├── dashboard.png
│ ├── dashboard1.png
│ ├── model.png
│ └── README_powerbi.md
│
├── .github/workflows/ # CI/CD pipelines
│ ├── ci.yml
│ └── cd.yml
│
├── Dockerfile # Container definition
├── requirements.txt # Python dependencies
├── .gitignore
├── .env # Environment variables (not committed)
└── README.md # Project documentation

## 🔐 Environment Variables

Create a `.env` file locally (DO NOT commit it):
SNOWFLAKE_ACCOUNT=...
SNOWFLAKE_USER=...
SNOWFLAKE_PASSWORD=...
SNOWFLAKE_WAREHOUSE=...
SNOWFLAKE_DATABASE=RETAIL_PROJECT
SNOWFLAKE_SCHEMA=MART
SNOWFLAKE_ROLE=...


## ▶️ Run Locally (No Docker)

```bash
python -m venv venv
source venv/bin/activate   # Windows: venv\Scripts\activate
pip install -r requirements.txt

uvicorn app.main:app --reload
Open:

http://127.0.0.1:8000/docs

docker build -t retail-api .
docker run -d -p 8000:8000 --name retail-api --env-file .env retail-api


🚀 Key Learnings

ELT patterns and layered architecture (RAW/STAGING/MART)

Building analytics-ready tables & views

RFM segmentation and customer clustering

Forecasting with SARIMA and exporting predictions

Power BI modeling + measures + slicers

Productizing analytics via FastAPI

Dockerizing services and automating CI/CD with GitHub Actions


