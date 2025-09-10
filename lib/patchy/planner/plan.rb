# frozen_string_literal: true

module Patchy
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
            Patchy::Project::TargetFile.new(source_file),
          ),
        )
      end

      def add(action)
        @actions << action
      end
    end
  end
end
