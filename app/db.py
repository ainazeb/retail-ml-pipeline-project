import os
import snowflake.connector
from dotenv import load_dotenv

load_dotenv()

def get_conn():
    """
    Create and return a Snowflake connection using env vars.
    """
    return snowflake.connector.connect(
        account=os.getenv("SNOWFLAKE_ACCOUNT"),
        user=os.getenv("SNOWFLAKE_USER"),
        password=os.getenv("SNOWFLAKE_PASSWORD"),
        warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
        database=os.getenv("SNOWFLAKE_DATABASE"),
        schema=os.getenv("SNOWFLAKE_SCHEMA"),
        role=os.getenv("SNOWFLAKE_ROLE"),
        session_parameters={
            "QUERY_TAG": os.getenv("SNOWFLAKE_QUERY_TAG", "retail-api")
        }
    )

def fetch_actual_vs_forecast(limit: int = 200):
    """
    Read from the view MART.V_REVENUE_ACTUAL_FORECAST
    """
    sql = f"""
        SELECT WeekStart, Series, Revenue
        FROM V_REVENUE_ACTUAL_FORECAST
        ORDER BY WeekStart
        LIMIT {int(limit)}
    """
    conn = get_conn()
    try:
        cur = conn.cursor()
        cur.execute(sql)
        rows = cur.fetchall()
        return rows
    finally:
        try:
            cur.close()
        except Exception:
            pass
        conn.close()
