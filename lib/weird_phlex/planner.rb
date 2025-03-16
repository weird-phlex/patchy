# frozen_string_literal: true

require 'weird_phlex/planner/plan'
require 'weird_phlex/indexer'

module WeirdPhlex
  class Planner
    def self.initial_full_installation_plan
      plan = Plan.new
      # we temporarily assume that the project is still empty
      WeirdPhlex::Indexer
        .component_pack_variants
        .flat_map(&:files)
        .reject(&:ignored?)
        .each { plan.create(_1) }

      plan
    end
  end
end
