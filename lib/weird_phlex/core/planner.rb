# frozen_string_literal: true

require 'weird_phlex/core/planner/plan'
require 'weird_phlex/core/indexer'

module WeirdPhlex
  module Core
    class Planner
      def self.initial_full_installation_plan
        plan = Plan.new
        # we temporarily assume that the project is still empty
        WeirdPhlex::Core::Indexer
          .component_pack_variants
          .flat_map(&:files)
          .select(&:component_file?)
          .each { plan.create(_1) }

        plan
      end
    end
  end
end
