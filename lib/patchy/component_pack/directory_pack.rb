# frozen_string_literal: true

module Patchy
  class ComponentPack
    class DirectoryPack < Patchy::ComponentPack
      def initialize(path)
        path = Pathname.new(path)

        super(
          name: path.basename.to_s,
          root_path: path
        )
      end

      class << self
        def all
          (component_packs.included - component_packs.excluded)
            .map { Pathname.new(_1) }
            .map { new(_1) }
        end

        private

        def file_component_candidates
          component_packs.included - component_packs.excluded
        end

        def component_packs
          Project.new.config.directory_pack_config
        end
      end
    end
  end
end
