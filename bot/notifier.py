from telegram import Bot
from utils.config import TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID

class TelegramNotifier:
    def __init__(self):
        self.bot = Bot(token=TELEGRAM_BOT_TOKEN)

    async def send_signal(self, signal):
        await self.bot.send_message(chat_id=TELEGRAM_CHAT_ID, text=signal)
