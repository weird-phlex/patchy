# frozen_string_literal: true

module WeirdPhlex
  class ComponentPack
    class NewComponent
      attr_reader :component_path, :relative_path, :type, :subdirectory, :pack

      def initialize(name, type:, pack:, subdirectory: [])
        @pack = pack
        @name = name
        @type = type # :global | :shared | :components
        @subdirectory = subdirectory


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

      def inspect
        "NEW COMPONENT: #{@canonical_name}"
      end

      def new_files
        Dir['**/*', base: @component_path.to_s]
          .reject { @component_path.join(_1).directory? }
          .map { normalize_filenames(_1) }
          .uniq
          .map { NewFile.new(_1, component: self) }
      end

      def normalize_filenames(name)
        name.gsub(%r(\.\d+\.(create|update|delete)), '')
      end

      def self.new_or_nil(relative_path, pack:)
        if relative_path == '_global_/'
          new('global', type: :global, pack:)
        elsif relative_path.start_with?('shared/')
          subdirectory = relative_path.delete_suffix('/').split('/')
          subdirectory.shift
          name = subdirectory.pop.delete_prefix('_').delete_suffix('_')
          new(name, type: :shared, pack:, subdirectory:)
        elsif relative_path.start_with?('components/')
          subdirectory = relative_path.delete_suffix('/').split('/')
          subdirectory.shift
          name = subdirectory.pop.delete_prefix('_').delete_suffix('_')
          new(name, type: :components, pack:, subdirectory:)
        else
          nil
        end
      end
    end
  end
end
