# frozen_string_literal: true

require 'weird_phlex/core/component_pack/variant'
require 'weird_phlex/core/project/file'
require 'weird_phlex/core/project/component'

module WeirdPhlex
  module Core
    class Indexer
      class << self
        def component_pack_variants
          WeirdPhlex::Core::ComponentPack::Variant.all
        end

        def project_files
          WeirdPhlex::Core::Project::File.all
        end

        def project_components
          WeirdPhlex::Core::Project::Component.all
        end
      end
    end
  end
end
