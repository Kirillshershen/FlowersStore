class TelegramController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]

  def webhook
    puts "=== webhook started ==="
    update = params.to_unsafe_h
    puts "Update params: #{update.inspect}"

    message = update['message'] || update[:message]
    puts "Message extracted: #{message.inspect}"

    if message && message['text'].present?
      text = message['text']
      chat_id = message.dig('chat', 'id')

      puts "Received text: #{text.inspect}, chat_id: #{chat_id.inspect}"

      if text.start_with?('/start')
        token = text.split(' ')[1]
        puts "Token extracted: #{token.inspect}"

        user = User.find_by(telegram_link_token: token)
        puts "User found: #{user.inspect}"

        if user
          if user.telegram_chat_id == chat_id
            puts "User already connected, sending message"
            send_message(chat_id, 'Вы уже подключены к Telegram.')
          else
            user.update(telegram_chat_id: chat_id)
            puts "User updated with telegram_chat_id"
            send_message(chat_id, 'Привет! Telegram успешно подключён.')
          end
        else
          puts "User not found, sending message"
          send_message(chat_id, 'Пользователь не найден.')
        end
      else
        puts "Unknown command, sending message"
        send_message(chat_id, 'Неизвестная команда.')
      end
    else
      puts "No message or text present"
    end

    puts "=== webhook finished ==="
    head :ok
  end

  private

  def send_message(chat_id, text)
    puts "Sending message to chat_id=#{chat_id.inspect} with text=#{text.inspect}"
    Rails.logger.info("Отправляю to chat_id=#{chat_id.inspect}, text=#{text.inspect}")

    begin
      TelegramBotService.bot_client.api.send_message(chat_id: chat_id, text: text)
      puts "Message sent successfully"
    rescue => e
      puts "Error while sending message: #{e.message}"
      Rails.logger.error("Error sending Telegram message: #{e.full_message}")
    end
  end
end
