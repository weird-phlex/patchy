# frozen_string_literal: true

require 'tmpdir'

module Patchy
  class Planner
    class Plan
      class CopyAction
        def initialize(source_file, target_file)
          @source_file = source_file
          @target_file = target_file
        end

        def perform!
          Dir.mktmpdir do |tmp_dir|
            pack_file = Pathname.new(tmp_dir).join(@source_file.raw_file.basename)
            FileUtils.copy(@source_file.raw_file, pack_file)

            Magician.new(pack_file).write!(@source_file)

            @target_file.raw_file.write(pack_file.read)
          end
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
