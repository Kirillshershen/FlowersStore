class TelegramController < ApplicationController
skip_before_action :verify_authenticity_token, only: [:webhook]


  def webhook
      Rails.logger.info "Telegram обновлениеууууууууууууу❌❌❌❌❌❌❌❌❌❌❌❌❌❌❌ууууууууууу: #{params.to_unsafe_h.inspect}"

    update = params.to_unsafe_h

    message = update["message"]
    return head :ok unless message.present?

    chat_id = message["chat"]["id"]
    text = message["text"]

    if text&.start_with?("/start ")
token = message.text.to_s.strip.split(' ')[1]
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
    Rails.logger.error "❌❌❌❌❌❌❌Telegram ошибка: #{e.class} — #{e.message}"
    head :internal_server_error
  end

  private

def send_message(chat_id, text)
  Telegram::Bot::Client.run(ENV["TELEGRAM_BOT_TOKEN"]) do |bot|
    bot.api.send_message(chat_id: chat_id, text: text)
  end
end

end
