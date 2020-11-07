# frozen_string_literal: true

module Attesteur
  class User
    MANDATORY_FIELDS = %w[
      first_name last_name
      birth_date birth_place
      zipcode town address
    ].freeze

    def initialize(id, infos = {})
      @id = id
      @infos = infos
      @greeted = false
      @subscribing = false
    end

    def fill(field, value)
      infos[field] = value.strip
      @subscribing = false if subscribed?
    end

    def greeted?
      @greeted
    end

    def greet!
      @greeted = true
    end

    def subscribing?
      @subscribing
    end

    def subscribing!
      @subscribing = true
    end

    def subscribed?
      missing_fields.empty?
    end

    def next_missing_field
      missing_fields.first
    end

    attr_reader :id
    attr_reader :infos

    private

    def missing_fields
      MANDATORY_FIELDS - infos.keys
    end
  end
end