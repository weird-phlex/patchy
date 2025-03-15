# frozen_string_literal: true

module WeirdPhlex
  module Project
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

      # library:, variant:,
      def initialize(component:, part:, file:)
        # @library = library
        # @variant = variant
        @component = component
        @part = part
        @file = file
      end

      def raw_file
        path = project_root.join(part_location, @file)
        ::FileUtils.mkdir_p(path.parent)
        ::FileUtils.touch(path)
        path
      end

      def part_location
        case @part
        when 'helper'
          'app/helpers/components'
        when 'partial'
          'app/views/components'
        when 'stimulus_controller'
          'app/javascript/controllers/components'
        else
          raise 'Unknown part'
        end
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
