# frozen_string_literal: true

module Attesteur
  module MessageProcessors
    class Base
      def initialize(brain, api)
        @brain = brain
        @api = api
      end

      private
      attr_reader :brain
      attr_reader :api
    end
  end
end