class TelegramNotifyJob < ApplicationJob
  queue_as :default

  def perform(chat_id, message)
    # Здесь вызываем метод отправки сообщения в Telegram
    TelegramNotifier.send_message(chat_id, message)
  end
end
  