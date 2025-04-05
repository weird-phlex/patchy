# frozen_string_literal: true

require 'weird_phlex/component_pack/new_component'
require 'weird_phlex/component_pack/component'
require 'weird_phlex/component_pack/config'
require 'weird_phlex/component_pack/file'

module WeirdPhlex
  class ComponentPack
    IMPLICIT_PACK_REGEX = /\Aweird_phlex_pack-(?<pack_name>.+)\Z/

    attr_reader :config, :root_path, :pack_path

    def initialize(gem_specification)
      @gem = gem_specification.name
      @name = gem_specification.name.delete_prefix('weird_phlex_pack-')
      @root_path = Pathname.new(gem_specification.gem_dir)
      @pack_path = @root_path.join('pack')
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
      file_paths.map { WeirdPhlex::ComponentPack::File.new(_1, component_path: @pack_path) }
    end

    def new_components
      global = []
      shared = []
      components = []

      if @pack_path.join('_global_').directory?
        global << NewComponent.new('global', type: :global, pack: self)
      end

      shared = dir_paths('shared')
        .select { |relative_path| relative_path.match? %r(_[^/]+_/\z) } # TODO: improve
        .map do |relative_path|
          parts = relative_path.delete_suffix('/').split('/')
          last = parts.pop.delete_prefix('_').delete_suffix('_')
          NewComponent.new(last, subdirectory: parts, type: :shared, pack: self)
        end
      components = dir_paths('components')
        .select { |relative_path| relative_path.match? %r(_[^/]+_/\z) } # TODO: improve
        .map do |relative_path|
          parts = relative_path.delete_suffix('/').split('/')
          last = parts.pop.delete_prefix('_').delete_suffix('_')
          NewComponent.new(last, subdirectory: parts, type: :components, pack: self)
        end

      [*global, *shared, *components]
    end

    private

    def file_paths
      Dir['**/*', base: @pack_path.to_s].map { @pack_path.join(_1) }.select(&:file?)
    end

    def dir_paths(name)
      Dir['**/', base: @pack_path.join(name).to_s]
    end
  end
end
