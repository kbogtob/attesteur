# frozen_string_literal: true

module Attesteur
  class Database
    DEFAULT_DIR = File.join(File.dirname(__FILE__), '../..', 'users')

    def initialize(path = nil)
      @path = path || DEFAULT_DIR
      FileUtils.mkdir_p(@path)
      @users = {}
    end

    # calls block if user created
    def find_or_create(user_id)
      # if not found in memory
      unless user = users[user_id]
        # load from file
        if user = load(user_id)
          users[user_id] = user
        else
          # if still not found, create user
          user = users[user_id] = User.new(user_id)
          # and yield
          yield user if block_given?
        end
      end

      user
    end

    def delete(user_id)
      users.delete(user_id)
      File.delete(user_path(user_id)) if File.exist?(user_path(user_id))
    end

    def save(user)
      File.write(user_path(user.id), YAML.dump(user.infos))
    end

    private
    attr_reader :users
    attr_reader :path

    def load(user_id)
      return nil unless File.exist?(user_path(user_id))

      infos = YAML.load_file(user_path(user_id))

      User.new(user_id, infos)
    end

    def user_path(user_id)
      File.join(path, "#{user_id}.yml")
    end
  end
end