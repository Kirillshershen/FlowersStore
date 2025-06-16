#!/usr/bin/env ruby
require_relative '../config/environment'

puts 'Starting bot'

Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_TOKEN'], logger: Rails.logger) do |bot|
  bot.listen do |message|
    puts "Incoming message: text=#{message.text.inspect} uid=#{message.chat.id}"
    TelegramBotService.handle_message(bot, message)
  end
end
