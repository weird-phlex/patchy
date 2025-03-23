# frozen_string_literal: true

module WeirdPhlex
  class Project
    class TargetFile
      # This class represents a not yet existing file in the target project.
      # We use this as a placeholder for the planner.

      def self.from_component_pack_file(file)
        new(
          component: file.component,
          part: file.part,
          file: file.file,
        )
      end

      def self.from_component_pack_shared_file(file)
        new(
          component: nil,
          part: file.part,
          file: file.file,
          shared: true,
        )
      end

      # library:, variant:,
      def initialize(component:, part:, file:, shared: false)
        # @library = library
        # @variant = variant
        @component = component
        @part = part
        @file = file
        @shared = shared
      end

      def raw_file
        path = project_root.join(part_location, @file)
        ::FileUtils.mkdir_p(path.parent)
        ::FileUtils.touch(path)
        path
      end

      def part_location
        path = if @shared
          Config.new.shared_part_path(@part)
        else
          Config.new.part_path(@part)
        end
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
