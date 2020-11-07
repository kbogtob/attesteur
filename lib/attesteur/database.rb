# frozen_string_literal: true

module Attesteur
  class Database
    DEFAULT_DIR = File.join(File.dirname(__FILE__), '../..', 'users')

    def initialize(path = nil)
      @path = path || DEFAULT_DIR
      FileUtils.mkdir_p(@path)
    end

    def exists?(user_id)
      File.exist?(user_path(user_id))
    end

    def load(user_id)
      return nil unless exists?(user_id)

      infos = YAML.load_file(user_path(user_id))

      User.new(user_id, infos)
    end

    def save(user)
      File.write(user_path(user.id), YAML.dump(user.infos))
    end

    def delete(user_id)
      if exists?(user_id)
        File.delete(user_path(user_id))
      end
    end

    private
    attr_reader :path

    def user_path(user_id)
      File.join(path, "#{user_id}.yml")
    end
  end
end