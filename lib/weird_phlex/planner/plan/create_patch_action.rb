# frozen_string_literal: true

module WeirdPhlex
  class Planner
    class Plan
      class CreatePatchAction
        def initialize(old_file, new_file)
          @old_file = old_file
          @new_file = new_file
        end

        def perform!
          create_patch_file
          @old_file.raw_file.write(@new_file.raw_file.write)
        end

        def create_patch_file
          out, err, status = Open3.capture3('git', 'diff', '--no-index', '--patch', @old_file.path, @new_file.path)
          touch_patch_file.write(out)
        end

        def touch_patch_file
          path = component_pack_root.join(part_location, @file)
          ::FileUtils.mkdir_p(path.parent)
          ::FileUtils.touch(path)
          path
        end

        def to_s
          <<~HEREDOC
            CREATE PATCH:
              #{@old_file}
              #{@new_file}
          HEREDOC
        end
      end
    end
  end
end
