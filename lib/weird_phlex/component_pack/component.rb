# frozen_string_literal: true

module WeirdPhlex
  class ComponentPack
    class Component
      attr_reader :files

      def initialize(name, files: [])
        @name = name
        @files = files
      end

      def to_s
        "#{@name} - #{@files.count} file#{'s' if @files.count != 1}"
      end
    end
  end
end
