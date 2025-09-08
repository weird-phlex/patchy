# frozen_string_literal: true

require 'patchy/planner/plan'

module Patchy
  class Planner
    def self.initial_full_installation_plan
      plan = Plan.new
      # we temporarily assume that the project is still empty
      Patchy::ComponentPack
        .all
        .flat_map(&:components)
        .flat_map(&:files)
        .each { plan.create(_1) }

      plan
    end
  end
end
