# frozen_string_literal: true

module WeirdPhlex
  class Planner
    class Plan
      class CopyAction
        def initialize(source_file, target_file)
          @source_file = source_file
          @target_file = target_file
        end

        def perform!
          @target_file.raw_file.write(@source_file.raw_file.read)
        end

        def to_s
          <<~HEREDOC
            COPY:
              #{@source_file}
              #{@target_file}
          HEREDOC
        end
      end
    end
  end
end
