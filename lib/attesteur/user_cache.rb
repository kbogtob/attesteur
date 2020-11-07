# frozen_string_literal: true

module Attesteur
  class UserCache
    def initialize(database)
      @database = database
      @cache = {}
    end

    def find_or_initialize(user_id)
      # return cached user if found
      return cache[user_id] if cache.key?(user_id)

      # cache and return user
      cache[user_id] =  if database.exists?(user_id)
                          # from DB if it exists
                          database.load(user_id)
                        else
                          # or initialize user
                          User.new(user_id)
                        end
    end

    def delete(user_id)
      database.delete(user_id)
      cache.delete(user_id)
    end

    private
    attr_reader :database
    attr_reader :cache
  end
end
