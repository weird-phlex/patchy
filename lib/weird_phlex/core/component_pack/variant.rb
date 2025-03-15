# frozen_string_literal: true

require 'open3'

require 'weird_phlex/core/component_pack/component'
require 'weird_phlex/core/component_pack/file'

module WeirdPhlex
  module Core
    module ComponentPack
      class Variant
        LIBRARAY_AND_VARIANT_REGEX = /\Aweird_phlex-(?<library>[_\w]+)-(?<variant>[_\w]+)\Z/.freeze

        def self.all
          # We assume that both `weird_phlex` and all component packs are loaded in Bundler group `:development`
          # and are thus available at the same time.
          Gem.loaded_specs
            .select { |name, _gem_specification| name.match(LIBRARAY_AND_VARIANT_REGEX) }
            .values
            .map { new(_1) }
        end

        def initialize(gem_specification)
          @name = gem_specification.name
          @gem = gem_specification.name
          @gem_path = Pathname.new(gem_specification.gem_dir)
          @library, @variant = library_and_variant(gem_specification.name)
          @component_path = @gem_path.join('lib', 'weird_phlex', @library, @variant)
        end

        def components
          files
            .select(&:component_file?)
            .group_by(&:component)
            .map do |component_name, files|
              WeirdPhlex::Core::ComponentPack::Component.new(component_name, files: files)
            end
        end

        def files
          file_paths.map { WeirdPhlex::Core::ComponentPack::File.new(_1, component_path: @component_path) }
        end

        private

        # Potentially use Gem::Specification.lib_files
        def file_paths
          Dir['**/*', base: @component_path.to_s].map { @component_path.join(_1) }.select(&:file?)
        end

        def library_and_variant(name)
          if (matches = name.match(LIBRARAY_AND_VARIANT_REGEX))
            [matches[:library], matches[:variant]]
          else
            raise "Regex error: Could not parse component pack name '#{name}'!"
          end
        end
      end
    end
  end
end
