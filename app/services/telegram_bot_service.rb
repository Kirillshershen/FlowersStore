class TelegramBotService
  def self.handle_message(bot, message)
    if message.text&.start_with?('/start')
      token = message.text.split(' ')[1]
      user = User.find_by(telegram_link_token: token)

      if user
        if user.telegram_chat_id == message.chat.id
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
