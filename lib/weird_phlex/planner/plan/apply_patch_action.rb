# frozen_string_literal: true

module WeirdPhlex
  class Planner
    class Plan
      class ApplyPatchAction
        def initialize(old_file, patch_file)
          @old_file = old_file
          @patch_file = patch_file
        end

        def perform!
          Open3.capture3('patch', '--merge', '--no-backup-if-mismatch', '--quiet', @old_file.path, @patch_file.path)
        end

        def to_s
          <<~HEREDOC
            APPLY PATCH:
              #{@old_file}
              #{@patch_file}
          HEREDOC
        end
      end
    end
  end
end
