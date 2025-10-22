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
          return [] unless config.use_default_packs || config.included.any?

          ::Gem.loaded_specs
            .select { |name, _gem_specification| used?(name) }
            .values
            .map { new(_1) }
        end

        private

        def used?(name)
          default = config.use_default_packs && name.match(IMPLICIT_PACK_REGEX)
          (default || name.in?(config.included)) && !name.in?(config.excluded)
        end

        def config
          Project.new.config.gem_pack_config
        end
      end
    end
  end
end
