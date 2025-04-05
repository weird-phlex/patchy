# frozen_string_literal: true

require 'weird_phlex/planner/plan'

module WeirdPhlex
  class Planner
    def self.initial_full_installation_plan
      plan = Plan.new
      # we temporarily assume that the project is still empty
      WeirdPhlex::ComponentPack
        .all
        .flat_map(&:components)
        .flat_map(&:files)
        .each { plan.create(_1) }

      plan
    end
  end
end
