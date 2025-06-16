class TelegramController < ApplicationController
skip_before_action :verify_authenticity_token, only: [:webhook]


  def webhook
      Rails.logger.info "Telegram обновлениеууууууууууууу❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ууууууууууу: #{params.to_unsafe_h.inspect}"

    update = params.to_unsafe_h

    message = update["message"]
    return head :ok unless message.present?

    chat_id = '8173550617:AAEHz6EBRS4yp3sWpzf7x4KpSS8sMUgiSwQ'
    text = message["text"]

    if text&.start_with?("/start ")
      token = text.split(" ").last
      user = User.find_by(telegram_link_token: token)

      if user
        user.update(telegram_chat_id: chat_id)
        send_message(chat_id, "✅ Telegram привязан к вашему аккаунту.")
      else
        send_message(chat_id, "❌ Ошибка: токен не найден.")
      end
    else
      send_message(chat_id, "Привет! Отправьте /start <токен> для привязки.")
    end

    head :ok
  rescue => e
    Rails.logger.error "Telegram webhook error: #{e.class} — #{e.message}"
    head :internal_server_error
  end

  private

  def send_message(chat_id, text)
    bot = Telegram::Bot::Client.new(ENV['TELEGRAM_BOT_TOKEN'])
    bot.api.send_message(chat_id: chat_id, text: text)
  end
end
