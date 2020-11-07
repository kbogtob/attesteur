# frozen_string_literal: true

module Attesteur
  module Generation
    class ERBEngine
      MOTIVATIONS = {
        'reason_work' => 'travail',
        'reason_food' => 'achats',
        'reason_health' => 'sante',
        'reason_family' => 'famille',
        'reason_handicap' => 'handicap',
        'reason_pets' => 'sport_animaux',
        'reason_sport' => 'sport_animaux',
        'reason_justice' => 'convocation',
        'reason_missions' => 'missions',
        'reason_school' => 'enfants',
      }.freeze

      def initialize(user, reason, time)
        @user = user
        @reason = reason
        @time = time

        @infos = user.infos
        @motivation = MOTIVATIONS[reason]
      end

      def template(erb)
        ERB.new(erb).result(binding)
      end

      private
      attr_reader :user
      attr_reader :reason
      attr_reader :time
    end
  end
end
