class TelegramController < ApplicationController
skip_before_action :verify_authenticity_token, only: [:webhook]


  def webhook
  update = params.to_unsafe_h  # или params[:message] - зависит от структуры
  message = update['message'] || update[:message]

  if message && message['text'].present?
    text = message['text']
    chat_id = message.dig('chat', 'id')

    if text.start_with?('/start')
      token = text.split(' ')[1]
      user = User.find_by(telegram_link_token: token)

      if user
        if user.telegram_chat_id == chat_id
          send_message(chat_id, 'Вы уже подключены к Telegram.')
        else
          user.update(telegram_chat_id: chat_id)
          send_message(chat_id, 'Привет! Telegram успешно подключён.')
        end
      else
        send_message(chat_id, 'Пользователь не найден.')
      end
    else
      send_message(chat_id, 'Неизвестная команда.')
    end
  end

  head :ok
end

def send_message(chat_id, text)
  TelegramBotService.bot_client.api.send_message(chat_id: chat_id, text: text)
end


  private

def send_message(chat_id, text)
  Telegram::Bot::Client.run(ENV["TELEGRAM_BOT_TOKEN"]) do |bot|
    bot.api.send_message(chat_id: chat_id, text: text)
  end
end

end
