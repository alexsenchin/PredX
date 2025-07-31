import httpx
import pandas as pd
import datetime

BASE_URL = "https://api.binance.com/api/v3/klines"

async def fetch_klines(symbol="BTCUSDT", interval="5m", limit=500):
    params = {"symbol": symbol, "interval": interval, "limit": limit}
    async with httpx.AsyncClient() as client:
        r = await client.get(BASE_URL, params=params)
        data = r.json()
    df = pd.DataFrame(data, columns=[
        "timestamp", "open", "high", "low", "close", "volume", "close_time",
        "qav", "num_trades", "taker_base_vol", "taker_quote_vol", "ignore"
    ])
    df["timestamp"] = pd.to_datetime(df["timestamp"], unit="ms")
    df = df.astype(float, errors="ignore")
    return df
