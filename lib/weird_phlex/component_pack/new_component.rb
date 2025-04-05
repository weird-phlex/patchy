# frozen_string_literal: true

module WeirdPhlex
  class ComponentPack
    class NewComponent
      attr_reader :files

      def initialize(name, type:, subdirectory: [], pack:, files: [])
        @pack = pack
        @name = name
        @type = type # :global | :shared | :components
        @subdirectory = subdirectory
        @files = files

        @canonical_name = if type == :global
          'global'
        else
          "#{type}/#{subdirectory.map { "#{_1}/" }.join}#{name}"
        end

        name_parts = @canonical_name.split('/')
        last = name_parts.pop
        name_parts << "_#{last}_"
        @relative_path = name_parts.join('/')
        @component_path = @pack.pack_path.join(*name_parts)
      end

      def to_s
        "#{@name} - #{@files.count} file#{'s' if @files.count != 1}"
      end

      def inspect
        "NEW COMPONENT: #{@canonical_name}"
      end
    end
  end
end
