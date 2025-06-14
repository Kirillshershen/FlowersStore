# app/services/telegram_bot_service.rb
require 'telegram/bot'

class TelegramBotService
  @bot_client = nil

  def self.bot_client
    @bot_client ||= Telegram::Bot::Client.new(ENV['TELEGRAM_BOT_TOKEN'])
  end

  def self.run
    bot_client.listen do |message|
      case message
      when Telegram::Bot::Types::Message
        handle_message(bot_client, message)
      end
    end
  end

  def self.send_message(chat_id, text)
    bot_client.api.send_message(chat_id: chat_id, text: text)
  end
  
def self.handle_message(bot, message)
      puts "Received message: #{message.text.inspect} from chat_id=#{message.chat.id}"
  if message.text&.start_with?('/start')
    token = message.text.split(' ')[1]
    user = User.find_by(telegram_link_token: token)

    if user
      if user.telegram_chat_id == message.chat.id
        # Уже привязан, не шлём повторно приветствие
        bot.api.send_message(chat_id: message.chat.id, text: 'Вы уже подключены к Telegram.')
      else
        user.update(telegram_chat_id: message.chat.id)
        bot.api.send_message(chat_id: message.chat.id, text: 'Привет! Telegram успешно подключён.')

      end
    else
      bot.api.send_message(chat_id: message.chat.id, text: 'Пользователь не найден.')
    end
  else
    bot.api.send_message(chat_id: message.chat.id, text: 'Неизвестная команда.')
  end
end

end
