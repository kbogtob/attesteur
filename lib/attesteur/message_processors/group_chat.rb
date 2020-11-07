# frozen_string_literal: true

require_relative 'base'

module Attesteur
  module MessageProcessors
    class GroupChat < Base
      def eligible?(user, message)
        message.is_a?(Telegram::Bot::Types::Message) &&
          message.chat.type != "private"
      end

      def consume_message(user, message)
        if (text = message.text) && text.downcase.include?("attestation")
          api.send_message(
            chat_id: message.chat.id,
            text: Texts::SLIDE_TO_DM
          )
        end

        :stop
      end
    end
  end
end
