# frozen_string_literal: true

require_relative 'base'

module Attesteur
  module MessageProcessors
    class Unsubscribed < Base
      def eligible?(user, message)
        !user.subscribed?
      end

      def consume_message(user, message)
        # if user is already subscribing
        if user.subscribing?
          # the message is an answer to a question
          user.fill(user.next_missing_field, message.text)

          # if subscription just finished
          if user.subscribed?
            # save user
            brain.save(user)

            # move to next processor
            return :next
          end
        else
          # mark that we started subscription
          user.subscribing!
        end

        # ask question
        api.send_message(
          chat_id: user.id,
          text: Texts.question_for(user.next_missing_field)
        )

        :stop
      end
    end
  end
end
