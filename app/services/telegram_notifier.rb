class TelegramController < ApplicationController


  def webhook
    update = Telegram::Bot::Types::Update.new(params.to_unsafe_h)

    # Обрабатываем только входящие сообщения
    if update.message
      TelegramBotService.handle_message(TelegramBotService.bot_client, update.message)
    end

    head :ok
  end
end
