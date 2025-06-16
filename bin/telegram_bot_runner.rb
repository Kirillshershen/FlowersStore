#!/usr/bin/env ruby
require_relative '../config/environment'

Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_TOKEN'], logger: Rails.logger) do |bot|
  bot.listen do |message|
    TelegramBotService.handle_message(bot, message)
  end
end
