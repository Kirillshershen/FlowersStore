require 'telegram/bot'
require 'dotenv/load'
token = ENV['TELEGRAM_BOT_TOKEN']
chat_id = "2059102507"

Telegram::Bot::Client.run(token) do |bot|
  bot.api.send_message(chat_id: chat_id, text: "Привет! Это тестовое сообщение от бота.")
end
