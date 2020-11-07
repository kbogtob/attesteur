# frozen_string_literal: true

module Attesteur
  module MessageProcessors

  end
end

require_relative 'message_processors/group_chat'
require_relative 'message_processors/new_user'
require_relative 'message_processors/forget'
require_relative 'message_processors/unsubscribed'
require_relative 'message_processors/subscribed'
