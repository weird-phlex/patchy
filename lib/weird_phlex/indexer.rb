# frozen_string_literal: true

require 'weird_phlex/component_pack/variant'
require 'weird_phlex/project/file'
require 'weird_phlex/project/component'

module WeirdPhlex
  class Indexer
    class << self
      def component_pack_variants
        WeirdPhlex::ComponentPack::Variant.all
      end

      def project_files
        WeirdPhlex::Project::File.all
      end

      def project_components
        WeirdPhlex::Project::Component.all
      end
    end
  end
end
