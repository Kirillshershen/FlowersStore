require 'telegram/bot'

token = ENV['TELEGRAM_BOT_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  puts "Bot started. Send any message to it..."
  bot.listen do |message|
    puts "Chat ID: #{message.chat.id}"
    puts "From: #{message.from.first_name} #{message.from.last_name}"
    break  # чтобы остановить после первого сообщения
  end
end
