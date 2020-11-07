# frozen_string_literal: true

module Attesteur
  class Cli
    def initialize(token)
      @token = token
    end

    def start
      Telegram::Bot::Client.run(token, logger: Logger.new($stderr)) do |bot|
        bot.logger.info("Starting bot!")
        BotBrain.new(bot).listen
      end
    end

    private
    attr_reader :token
  end
end
