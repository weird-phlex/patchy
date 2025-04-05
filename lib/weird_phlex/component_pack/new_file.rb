# frozen_string_literal: true

module WeirdPhlex
  class ComponentPack
    class NewFile
      attr_reader :component, :part, :file, :raw_file, :relative_path, :relative_path_without_part

      def initialize(relative_path, component:)
        @relative_path = relative_path
        @relative_path_without_part = relative_path.gsub(%r(\A[^/]+/), '')
        @component = component
        @path = @component.component_path.join(relative_path)
        @raw_file = @path

        matches = @relative_path.match(%r{\A(?<part>[^/]*)/(?<file>.*)})
        @part = matches[:part]
        @file = matches[:file]
      end

      def inspect
        "FILE #{@component.relative_path} - #{@relative_path}"
      end
    end
  end
end
