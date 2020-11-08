# frozen_string_literal: true

require_relative 'base'

module Attesteur
  module MessageProcessors
    class Subscribed < Base
      ACCEPTABLE_REASONS = %w[
        reason_work
        reason_food
        reason_health
        reason_sport
        reason_family
        reason_pets
        reason_school
      ].freeze

      def initialize(*args)
        super(*args)
        @generator = Generation::Generator.new
      end

      def eligible?(user, message)
        user.subscribed?
      end

      def consume_message(user, message)
        case message
        when Telegram::Bot::Types::CallbackQuery
          process_callback(message, user)
        when Telegram::Bot::Types::Message
          show_menu(user)
        end

        :stop
      end

      private
      attr_reader :generator

      def process_callback(message, user)
        if ACCEPTABLE_REASONS.include?(message.data)
          send_certificate(user, message.data)
        elsif message.data == 'help'
          api.send_message(chat_id: user.id, text: Texts::HELP)
        else
          api.send_message(chat_id: user.id, text: Texts::UNKNOWN)
        end
      end

      def send_certificate(user, reason)
        api.send_message(chat_id: user.id, text: Texts::GENERATING)

        certificate = generator.generate(user, reason)

        api.send_document(
          chat_id: user.id,
          document: certificate.pdf_upload_io,
          file_name: certificate.pdf_name
        )
        api.send_photo(
          chat_id: user.id,
          photo: certificate.qr_code_upload_io,
          file_name: certificate.qr_code_name
        )

        api.send_message(chat_id: user.id, text: Texts::BYE)
      end

      def show_menu(user)
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(
          inline_keyboard: KEYBOARD
        )

        api.send_message(
          chat_id: user.id,
          text: Texts::GENERATE,
          reply_markup: markup
        )
      end

      KEYBOARD = [
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
    end
  end
end
