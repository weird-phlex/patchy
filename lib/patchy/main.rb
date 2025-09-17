# frozen_string_literal: true

module Patchy
  class Main
    class << self

      def add(*args)
        glob_patterns = args.map do |glob|
          parts = glob.split('/')
          { pack: parts.first, component: parts.last }
        end

        available_components = Patchy::ComponentPack.all.flat_map(&:components)

        selected_components = available_components.select do |component|
          glob_patterns.any? do |glob_pattern|
            (glob_pattern[:pack] == '*' || glob_pattern[:pack] == component.pack.gem) &&
              (glob_pattern[:component] == '*' || glob_pattern[:component] == component.name)
          end
        end

        plan = Patchy::Planner::Plan.new
        selected_components
          .flat_map(&:files)
          .each { plan.create(_1) }

        plan.perform!
      end

    end
  end
end
