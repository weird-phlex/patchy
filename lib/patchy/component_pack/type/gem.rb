# frozen_string_literal: true

module Patchy
  class ComponentPack
    module Type
      class Gem < Patchy::ComponentPack
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
            if component_packs.is_a? Array
              name.in? component_packs
            else
              name.in?(component_packs.to_h['include'].to_a) ||
                name.match(IMPLICIT_PACK_REGEX)
            end
          end

          def exclude?(name)
            return false unless component_packs.is_a?(Hash)

            name.in?(component_packs['exclude'].to_a)
          end

          def component_packs
            Project.new.config.config['component_packs']
          end
        end
      end
    end
  end
end
