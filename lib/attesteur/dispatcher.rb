# frozen_string_literal: true

module Attesteur
  class Dispatcher
    def initialize(processors)
      @processors = processors
    end

    def dispatch(user, message)
      called_processors = 0

      processors.each do |processor|
        next unless processor.eligible?(user, message)

        called_processors += 1
        break if processor.consume_message(user, message) == :stop
      end

      called_processors
    end

    private
    attr_reader :processors
  end
end
