#!/bin/bash
# Полный проект PredX + авто пуш

# Создание структуры
mkdir -p bot core utils models data

# README
cat <<EOF > README.md
# PredX
AI-based Bitcoin price prediction bot.
EOF

# requirements.txt
cat <<EOF > requirements.txt
numpy
pandas
scikit-learn
lightgbm
ta
python-telegram-bot
httpx
python-dotenv
matplotlib
loguru
EOF

# .env.example
cat <<EOF > .env.example
BINANCE_API_KEY=your_api_key
BINANCE_API_SECRET=your_api_secret
TELEGRAM_BOT_TOKEN=your_bot_token
TELEGRAM_CHAT_ID=your_chat_id
EOF

# utils/config.py
mkdir -p utils
cat <<EOF > utils/config.py
import os
from dotenv import load_dotenv

load_dotenv()

BINANCE_API_KEY = os.getenv("BINANCE_API_KEY")
BINANCE_API_SECRET = os.getenv("BINANCE_API_SECRET")
TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
TELEGRAM_CHAT_ID = os.getenv("TELEGRAM_CHAT_ID")
EOF

# utils/logger.py
cat <<EOF > utils/logger.py
from loguru import logger
logger.add("predx.log", rotation="1 day")
EOF

# core/data_fetcher.py
mkdir -p core
cat <<EOF > core/data_fetcher.py
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
EOF

# core/indicators.py
cat <<EOF > core/indicators.py
import ta
import pandas as pd

def add_indicators(df: pd.DataFrame):
    df["rsi"] = ta.momentum.RSIIndicator(df["close"]).rsi()
    df["macd"] = ta.trend.MACD(df["close"]).macd()
    df["ema_20"] = ta.trend.EMAIndicator(df["close"], 20).ema_indicator()
    df["ema_50"] = ta.trend.EMAIndicator(df["close"], 50).ema_indicator()
    bb = ta.volatility.BollingerBands(df["close"])
    df["bb_high"] = bb.bollinger_hband()
    df["bb_low"] = bb.bollinger_lband()
    df["stoch"] = ta.momentum.StochasticOscillator(df["high"], df["low"], df["close"]).stoch()
    df["atr"] = ta.volatility.AverageTrueRange(df["high"], df["low"], df["close"]).average_true_range()
    df["obv"] = ta.volume.OnBalanceVolumeIndicator(df["close"], df["volume"]).on_balance_volume()
    df["adx"] = ta.trend.ADXIndicator(df["high"], df["low"], df["close"]).adx()
    df["cci"] = ta.trend.CCIIndicator(df["high"], df["low"], df["close"]).cci()
    df["momentum"] = ta.momentum.WilliamsRIndicator(df["high"], df["low"], df["close"]).williams_r()
    df["roc"] = ta.momentum.ROCIndicator(df["close"]).roc()
    df["price_change"] = df["close"].pct_change()
    df["ema_gap"] = df["ema_20"] - df["ema_50"]
    df.dropna(inplace=True)
    return df
EOF

# core/model.py
cat <<EOF > core/model.py
import lightgbm as lgb
import pandas as pd
import joblib
import os

MODEL_PATH = "models/predx_model.pkl"

def train_model(df: pd.DataFrame):
    features = [col for col in df.columns if col not in ["timestamp", "close"]]
    df["target"] = (df["close"].shift(-1) > df["close"]).astype(int)
    df.dropna(inplace=True)
    X, y = df[features], df["target"]
    model = lgb.LGBMClassifier()
    model.fit(X, y)
    os.makedirs("models", exist_ok=True)
    joblib.dump(model, MODEL_PATH)
    return model

def load_model():
    if os.path.exists(MODEL_PATH):
        return joblib.load(MODEL_PATH)
    return None
EOF

# core/predictor.py
cat <<EOF > core/predictor.py
from core.data_fetcher import fetch_klines
from core.indicators import add_indicators
from core.model import train_model, load_model
import pandas as pd

class Predictor:
    async def run(self):
        df = await fetch_klines()
        df = add_indicators(df)
        model = load_model()
        if model is None:
            model = train_model(df)
        features = [col for col in df.columns if col not in ["timestamp", "close"]]
        latest = df.iloc[-1:][features]
        prob = model.predict_proba(latest)[0][1]
        if prob > 0.7:
            return f"📈 Long signal ({prob*100:.2f}%)"
        elif prob < 0.3:
            return f"📉 Short signal ({(1-prob)*100:.2f}%)"
        return None
EOF

# bot/notifier.py
mkdir -p bot
cat <<EOF > bot/notifier.py
from telegram import Bot
from utils.config import TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID

class TelegramNotifier:
    def __init__(self):
        self.bot = Bot(token=TELEGRAM_BOT_TOKEN)

    async def send_signal(self, signal):
        await self.bot.send_message(chat_id=TELEGRAM_CHAT_ID, text=signal)
EOF

# main.py
cat <<EOF > main.py
from core.predictor import Predictor
from bot.notifier import TelegramNotifier
import asyncio

async def main():
    predictor = Predictor()
    notifier = TelegramNotifier()
    signal = await predictor.run()
    if signal:
        await notifier.send_signal(signal)

if __name__ == "__main__":
    asyncio.run(main())
EOF

# Dockerfile
cat <<EOF > Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "main.py"]
EOF

# Git push
git add .
git commit -m "Full PredX project with ML and Telegram bot"
git push -u origin main
