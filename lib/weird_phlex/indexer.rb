# frozen_string_literal: true

require 'weird_phlex/component_pack'
require 'weird_phlex/project'

module WeirdPhlex
  class Indexer
    class << self
      def component_pack_variants
        WeirdPhlex::ComponentPack.new.all_variants
      end

      def project_files
        WeirdPhlex::Project.new.all_files
      end

      def project_components
        WeirdPhlex::Project.new.all_components
      end
    end
  end
end
