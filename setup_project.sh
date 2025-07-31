#!/bin/bash
# Автоматическое создание структуры проекта PredX и пуш на GitHub

# --- Папки ---
mkdir -p bot core utils

# --- Файлы ---
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

# Пустые файлы в пакетах
touch bot/__init__.py core/__init__.py utils/__init__.py

# Dockerfile
cat <<EOF > Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "main.py"]
EOF

# --- Гит ---
git add .
git commit -m "Setup project structure"
git push -u origin main
