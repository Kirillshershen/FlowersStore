# config/initializers/telegram_bot.rb
require 'telegram/bot'

Rails.application.config.telegram_bot = Telegram::Bot::Client.new(ENV['TELEGRAM_BOT_TOKEN'])
