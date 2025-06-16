class TelegramController < ApplicationController
  skip_before_action :verify_authenticity_token

  def webhook
    update = Telegram::Bot::Types::Update.new(params.to_unsafe_h)

    if update.message
      TelegramBotService.handle_message(TelegramBotService.bot_client, update.message)
    end

    head :ok
  end
end
