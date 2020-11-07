# frozen_string_literal: true

require_relative 'base'

module Attesteur
  module MessageProcessors
    class NewUser < Base
      def eligible?(user, message)
        !user.greeted? && !user.subscribed?
      end

      def consume_message(user, message)
        api.send_message(
          chat_id: user.id,
          text: Texts::SUBSCRIPTION
        )

        user.greet!

        :next
      end
    end
  end
end
