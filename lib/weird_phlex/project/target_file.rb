# frozen_string_literal: true

module WeirdPhlex
  class Project
    class TargetFile
      # This class represents a not yet existing file in the target project.
      # We use this as a placeholder for the planner.

      def initialize(file)
        @file = file
      end

      def raw_file
        path = project_root.join(part_location, *@file.component.subdirectory, @file.relative_path_without_part)
        ::FileUtils.mkdir_p(path.parent)
        ::FileUtils.touch(path)
        path
      end

      def part_location
        path = Config.new.part_path(@file.component.type, @file.part)
        raise 'Unknown part' if path.blank?

        path
      end

      # A bit naive, copied from File
      def project_root
        Pathname.new(Dir.pwd)
      end

      def to_s
        "PLACEHOLDER: #{part_location}/#{@file}"
      end
    end
  end
end
