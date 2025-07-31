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
