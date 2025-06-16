Rails.application.config.after_initialize do
  if defined?(Telegram)
    Telegram.bots_config = {
      default: {
        token: ENV['TELEGRAM_BOT_TOKEN'],
        username: ENV['TELEGRAM_BOT_USERNAME']
      }
    }
  end
end
