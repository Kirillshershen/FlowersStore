class TelegramController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    bot_token = '8173550617:AAEHz6EBRS4yp3sWpzf7x4KpSS8sMUgiSwQ'
    Telegram::Bot::Client.run(bot_token) do |bot|
      update = Telegram::Bot::Types::Update.new(params[:update])
      message = update.message

      if message
        chat_id = message.chat.id
        user_code = message.text

        user = User.find_by(link_token: user_code)

        if user
          user.update(telegram_id: chat_id)
          bot.api.send_message(chat_id: chat_id, text: "✅ Аккаунт успешно привязан!")
        else
          bot.api.send_message(chat_id: chat_id, text: "❌ Код не найден. Попробуй ещё раз.")
        end
      end
    end

    head :ok
  end
end
