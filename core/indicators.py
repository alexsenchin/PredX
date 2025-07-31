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
