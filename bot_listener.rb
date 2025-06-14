    require 'telegram/bot'
    require 'dotenv/load'
    require_relative 'config/environment'  # чтобы подгрузить Rails и модели User

    Telegram::Bot::Client.run(ENV['TELEGRAM_BOT_TOKEN']) do |bot|
    bot.listen do |message|
        if message.text&.start_with?('/start')
        token = message.text.split(' ')[1]
        user = User.find_by(telegram_link_token: token)

        if user
            user.update(telegram_chat_id: message.chat.id)
            bot.api.send_message(chat_id: message.chat.id, text: 'Привет! Вы успешно связали Telegram с вашим аккаунтом.')
        else
            bot.api.send_message(chat_id: message.chat.id, text: 'Пользователь не1 найден.')
        end
        end
    end
    end
