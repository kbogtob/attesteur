# frozen_string_literal: true

module Attesteur
  class BotBrain
    ACCEPTABLE_REASONS = %w[
      reason_work
      reason_food
      reason_health
      reason_sport
      reason_family
      reason_pets
      reason_school
    ].freeze

    def initialize(bot)
      @bot = bot
      @database = Database.new
      @generator = Generation::Generator.new
    end

    def listen
      bot.listen do |message|
        # Invite people to chat in private
        bot.logger.info(message.inspect)
        if message.is_a?(Telegram::Bot::Types::Message) && message.chat.type != "private"
          if (text = message.text) && text.downcase.include?("attestation")
            bot.api.send_message(chat_id: message.chat.id, text: Texts::SLIDE_TO_DM)
          end

          next
        end

        # now we are in private chat
        # identify user
        user = database.find_or_create(message.from.id) do |user|
          # if new user, greet user and move on
          bot.api.send_message(chat_id: user.id, text: Texts::SUBSCRIPTION)
          next
        end

        # if user asks to be forgotten, nod and delete user
        if message.is_a?(Telegram::Bot::Types::Message) && message.text == '/forget'
          bot.api.send_message(chat_id: user.id, text: Texts::FORGETING)
          database.delete(user.id)
          next
        end

        # if the user hasn't subscribed yet
        if !user.subscribed?
          # follow the subscription process
          subscribe_process(user, message)
        end

        # if the user is subscribed or just has finished subscribing
        if user.subscribed?
          # propose menu
          menu(user, message)
        end
      end
    end

    private
    attr_reader :bot
    attr_reader :database
    attr_reader :generator

    def subscribe_process(user, message)
      return unless message.is_a?(Telegram::Bot::Types::Message)

      if user.subscribing?
        user.fill(user.next_missing_field, message.text)

        # if subscription just finished
        if user.subscribed?
          # save user and move on
          database.save(user)
          return
        end
      else
        user.subscribing!
      end

      bot.api.send_message(chat_id: user.id, text: Texts.question_for(user.next_missing_field))
    end

    def menu(user, message)
      case message
      when Telegram::Bot::Types::CallbackQuery
        process_callback(message, user)
      when Telegram::Bot::Types::Message
        reasons = [
          Telegram::Bot::Types::InlineKeyboardButton.new(
            text: Texts::REASON_WORK,
            callback_data: 'reason_work'
          ),
          Telegram::Bot::Types::InlineKeyboardButton.new(
            text: Texts::REASON_FOOD,
            callback_data: 'reason_food'
          ),
          Telegram::Bot::Types::InlineKeyboardButton.new(
            text: Texts::REASON_HEALTH,
            callback_data: 'reason_health'
          ),
          Telegram::Bot::Types::InlineKeyboardButton.new(
            text: Texts::REASON_SPORT,
            callback_data: 'reason_sport'
          ),
          Telegram::Bot::Types::InlineKeyboardButton.new(
            text: Texts::REASON_FAMILY,
            callback_data: 'reason_family'
          ),
          Telegram::Bot::Types::InlineKeyboardButton.new(
            text: Texts::REASON_PETS,
            callback_data: 'reason_pets'
          ),
          Telegram::Bot::Types::InlineKeyboardButton.new(
            text: Texts::REASON_SCHOOL,
            callback_data: 'reason_school'
          ),
          Telegram::Bot::Types::InlineKeyboardButton.new(
            text: Texts::HELP_ME,
            callback_data: 'help'
          ),
        ]

        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: reasons)

        bot.api.send_message(chat_id: user.id, text: Texts::GENERATE, reply_markup: markup)
      end
    end

    def process_callback(message, user)
      if ACCEPTABLE_REASONS.include?(message.data)
        send_certificate(user, message.data)
      elsif message.data == 'help'
        bot.api.send_message(chat_id: user.id, text: Texts::HELP)
      else
        bot.api.send_message(chat_id: user.id, text: Texts::UNKNOWN)
      end
    end

    def send_certificate(user, reason)
      bot.api.send_message(chat_id: user.id, text: Texts::GENERATING)
      certificate = generator.generate(user, reason)

      bot.api.send_document(chat_id: user.id, document: certificate.pdf_upload_io, file_name: certificate.pdf_name)
      bot.api.send_photo(chat_id: user.id, photo: certificate.qr_code_upload_io, file_name: certificate.qr_code_name)
    end
  end
end
