# frozen_string_literal: true

module Patchy
  class ComponentPack
    class GemPack < Patchy::ComponentPack
      IMPLICIT_PACK_REGEX = /\Apatchy_pack-(?<pack_name>.+)\Z/

      def initialize(gem_specification)
        super(
          name: gem_specification.name.delete_prefix('patchy_pack-'),
          root_path: gem_specification.gem_dir
        )
      end

      class << self
        def all
          return [] unless any_candidate?

          ::Gem.loaded_specs
            .select { |name, _gem_specification| include?(name) }
            .reject { |name, _gem_specification| exclude?(name) }
            .values
            .map { new(_1) }
        end

        private

        def any_candidate?
          if component_packs.is_a? Array
            component_packs.any? { _1.exclude?('/') }
          else
            true
          end
        end

        def include?(name)
          return true if name.in? component_packs.included

          component_packs.use_default_packs && name.match(IMPLICIT_PACK_REGEX)
        end

        def exclude?(name)
          name.in? component_packs.excluded
        end

        def component_packs
          Project.new.config.gem_pack_config
        end
      end
    end
  end
end
