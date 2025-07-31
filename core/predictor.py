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
