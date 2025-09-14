# frozen_string_literal: true

module Patchy
  class Main
    class << self
      def add(_args = nil)
        Patchy::Planner.initial_full_installation_plan.perform!
      end
    end
  end
end
