# frozen_string_literal: true

module WeirdPhlex
  class Main
    class << self
      def generate(_args)
        WeirdPhlex::Planner.initial_full_installation_plan_2.perform!
      end
    end
  end
end
