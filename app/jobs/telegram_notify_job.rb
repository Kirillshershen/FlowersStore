class TelegramNotifyJob < ApplicationJob
  queue_as :default

  def perform(chat_id, message)

    TelegramNotifier.send_message(chat_id, message)
  end
end
  