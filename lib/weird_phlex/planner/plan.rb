# frozen_string_literal: true

require 'weird_phlex/project/target_file'
require 'weird_phlex/planner/plan/copy_action'

module WeirdPhlex
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
        if source_file.shared?
          add(
            CopyAction.new(
              source_file,
              WeirdPhlex::Project::TargetFile.from_component_pack_shared_file(source_file),
            ),
          )
        else
          add(
            CopyAction.new(
              source_file,
              WeirdPhlex::Project::TargetFile.from_component_pack_file(source_file),
            ),
          )
        end
      end

      def create_2(source_file)
        add(
          CopyAction.new(
            source_file,
            WeirdPhlex::Project::TargetFile.from_new_file(source_file),
          ),
        )
      end

      def add(action)
        @actions << action
      end
    end
  end
end
