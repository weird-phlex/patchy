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
          (config.included - config.excluded).map { new(_1) }
        end

        private

        def config
          Project.new.config.directory_pack_config
        end
      end
    end
  end
end
