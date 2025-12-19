from pydantic import BaseModel
from datetime import date

class RevenuePoint(BaseModel):
    weekstart: date
    series: str
    revenue: float

class Message(BaseModel):
    message: str
