Telegram.bots_config = {
  default: {
    token: Rails.application.credentials.dig(:telegram, :bot_token)
  }
}
