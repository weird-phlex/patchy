# frozen_string_literal: true

require 'weird_phlex/component_pack/component'
require 'weird_phlex/component_pack/config'
require 'weird_phlex/component_pack/file'
require 'weird_phlex/component_pack/variant'

module WeirdPhlex
  class ComponentPack
    attr_reader :config, :root_path

    def initialize
      # very naive, assumes binary is run from Rails root, hardcoded pack name
      @root_path = Pathname.new(Dir.pwd).parent.join('weird_phlex_pack-dev_component_pack-testing')
      @config = Config.new
    end

    def all_variants
      Variant.all
    end
  end
end
