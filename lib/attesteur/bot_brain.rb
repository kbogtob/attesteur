# frozen_string_literal: true

module Attesteur
  class BotBrain
    def initialize(bot)
      @bot = bot
      @database = Database.new
      @user_cache = UserCache.new(database)
      @dispatcher = Dispatcher.new([
        MessageProcessors::GroupChat.new(self, bot.api),
        MessageProcessors::NewUser.new(self, bot.api),
        MessageProcessors::Forget.new(self, bot.api),
        MessageProcessors::Unsubscribed.new(self, bot.api),
        MessageProcessors::Subscribed.new(self, bot.api),
      ])
    end

    def listen
      bot.listen do |message|
        user = user_cache.find_or_initialize(message.from.id)
        dispatcher.dispatch(user, message)
      end
    end

    def save(user)
      database.save(user)
    end

    def delete(user)
      user_cache.delete(user.id)
    end

    private
    attr_reader :bot
    attr_reader :database
    attr_reader :user_cache
    attr_reader :dispatcher
  end
end
