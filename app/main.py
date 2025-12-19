from fastapi import FastAPI, Query
from typing import List
from .db import fetch_actual_vs_forecast
from .schemas import RevenuePoint, Message

app = FastAPI(title="Retail Forecast API", version="0.1.0")

@app.get("/", response_model=Message)
def root():
    return {"message": "Retail Forecast API is running"}

@app.get("/revenue/actual-vs-forecast", response_model=List[RevenuePoint])
def revenue_actual_vs_forecast(
    limit: int = Query(default=200, ge=1, le=5000)
):
    rows = fetch_actual_vs_forecast(limit=limit)
    # rows: [(weekstart, series, revenue), ...]
    return [
        RevenuePoint(weekstart=r[0], series=r[1], revenue=float(r[2]))
        for r in rows
    ]
