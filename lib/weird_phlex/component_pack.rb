# frozen_string_literal: true

require 'weird_phlex/component_pack/component'
require 'weird_phlex/component_pack/config'
require 'weird_phlex/component_pack/file'

module WeirdPhlex
  class ComponentPack
    IMPLICIT_PACK_REGEX = /\Aweird_phlex_pack-(?<pack_name>.+)\Z/

    attr_reader :config, :root_path

    def initialize(gem_specification)
      @gem = gem_specification.name
      @name = gem_specification.name.delete_prefix('weird_phlex_pack-')
      @root_path = Pathname.new(gem_specification.gem_dir)
      @component_path = @root_path.join('pack')
      @config = Config.new(@root_path)
    end

    def self.all(*explicit_pack_names)
      all_gem_specifications(*explicit_pack_names).map { new(_1) }
    end

    # We assume that both `weird_phlex` and all component packs are loaded in Bundler group `:development`
    # and are thus available at the same time.
    def self.all_gem_specifications(*explicit_pack_names)
      Gem.loaded_specs
        .select { |name, _gem_specification| pack_name?(name, explicit_pack_names:) }
        .values
    end

    def self.pack_name?(name, explicit_pack_names:)
      name.match(IMPLICIT_PACK_REGEX) || explicit_pack_names.include?(name)
    end

    def components
      files
        .select(&:component_file?)
        .group_by(&:component)
        .map do |component_name, files|
          WeirdPhlex::ComponentPack::Component.new(component_name, files: files)
        end
    end

    def files
      file_paths.map { WeirdPhlex::ComponentPack::File.new(_1, component_path: @component_path) }
    end

    private

    # Potentially use Gem::Specification.lib_files
    def file_paths
      Dir['**/*', base: @component_path.to_s].map { @component_path.join(_1) }.select(&:file?)
    end
  end
end
