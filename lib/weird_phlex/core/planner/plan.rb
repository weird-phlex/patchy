# frozen_string_literal: true

require 'weird_phlex/core/project/target_file'
require 'weird_phlex/core/planner/plan/copy_action'

module WeirdPhlex
  module Core
    class Planner
      class Plan
        attr_reader :actions

        def initialize(_actions = [])
          @actions = []
        end

        def perform!
          actions.each(&:perform!)
        end

        def to_s
          actions.each { puts _1 }
        end

        def copy(source_file, target_file)
          add(CopyAction.new(source_file, target_file))
        end

        def create(source_file)
          add(
            CopyAction.new(
              source_file,
              WeirdPhlex::Core::Project::TargetFile.from_component_pack_file(source_file),
            ),
          )
        end

        def add(action)
          @actions << action
        end
      end
    end
  end
end
