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
