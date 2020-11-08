# frozen_string_literal: true

require_relative 'base'

module Attesteur
  module MessageProcessors
    class Forget < Base
      def eligible?(user, message)
        message.is_a?(Telegram::Bot::Types::Message) &&
          (text = message.text) &&
          text.downcase.include?("/forget")
      end

      def consume_message(user, message)
        api.send_message(
          chat_id: user.id,
          text: Texts::FORGETING
        )

        brain.delete(user)

        :stop
      end
    end
  end
end
