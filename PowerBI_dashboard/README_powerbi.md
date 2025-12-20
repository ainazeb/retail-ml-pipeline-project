# Power BI Dashboard (Retail ML Pipeline)

This dashboard provides business-facing analytics for retail performance, sales forecasting, and RFM-based customer segmentation.  
It is built on curated Snowflake views and ML outputs (forecast + customer clusters).

---

## Dashboard Pages

### Page 1 — Retail Sales Performance & Forecast
This page delivers an executive overview of revenue performance:
- **Total Revenue KPI** for quick business monitoring
- **Revenue trend over time** to identify seasonality and sales spikes
- **Revenue by Country** to highlight top contributing markets
- **Actual vs Forecast comparison** to showcase ML forecasting outputs
- **Country slicer** for interactive filtering and drill-down analysis

**Key insight:** The page combines core KPIs with time-series trends and forecasting, enabling data-driven planning and performance tracking.

---

### Page 2 — RFM-Based Customer Clustering
This page focuses on customer segmentation using RFM features and clustering:
- **Customer distribution by cluster** (share of customers per segment)
- **Revenue by cluster** to identify high-value segments
- **Cluster slicer** to filter and explore each segment interactively

**Key insight:** The dashboard highlights which customer segments contribute the most revenue, supporting targeted marketing and retention strategies.

---

## Data Model
The report uses a fact-and-views analytical model:
- `FCT_DAILY_SALES` as the main sales fact table
- Customer feature views (`V_CUSTOMER_FEATURES`, `V_CUSTOMER_FEATURES_WITH_CLUSTER`)
- Forecast view (`V_REVENUE_ACTUAL_FORECAST`) with `SERIES` (Actual/Forecast)
- Analytical retail view (`V_RETAIL_FOR_ANALYTICS`) for enriched reporting

This design supports a clean workflow where Snowflake transformations and ML outputs are consumed directly by Power BI.

---

## Files
- `retail.dashboard.pbix` – Power BI report file  
- `dashboard.png` – Page 2 screenshot (Customer Clustering)  
- `dashboard1.png` – Page 1 screenshot (Sales & Forecast)  
- `model.png` – Data model / relationships screenshot  
