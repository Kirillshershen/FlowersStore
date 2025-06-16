class TelegramNotifier
  def self.send_message(chat_id, message)
    return if chat_id.blank?
    
    Telegram::Bot::Client.new(ENV['TELEGRAM_BOT_TOKEN']).api.send_message(
      chat_id: chat_id,
      text: message
    )
  end
end
