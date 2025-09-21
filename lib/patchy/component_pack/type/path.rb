# frozen_string_literal: true

module Patchy
  class ComponentPack
    module Type
      class Path < Patchy::ComponentPack
        def initialize(path)
          path = Pathname.new(path)

          super(
            name: path.basename.to_s,
            root_path: path
          )
        end

        class << self
          def all
            file_component_candidates
              .select { _1.include?('/') }
              .map { Pathname.new(_1) }
              .map { new(_1) }
          end

          private

          def file_component_candidates
            case component_packs
            when nil
              []
            when Array
              component_packs
            when Hash
              component_packs['include'].to_a -
                component_packs['exclude'].to_a
            end
          end

          def component_packs
            Project.new.config.config['component_packs']
          end
        end
      end
    end
  end
end
