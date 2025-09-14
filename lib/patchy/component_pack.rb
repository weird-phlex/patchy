# frozen_string_literal: true

module Patchy
  class ComponentPack
    IMPLICIT_PACK_REGEX = /\Apatchy_pack-(?<pack_name>.+)\Z/

    attr_reader :config, :root_path, :pack_path, :gem

    def initialize(gem_specification)
      @gem = gem_specification.name
      @name = gem_specification.name.delete_prefix('patchy_pack-')
      @root_path = Pathname.new(gem_specification.gem_dir)
      @pack_path = @root_path.join('pack')
      @config = Config.new(@root_path)
    end

    def self.all(*explicit_pack_names)
      all_gem_specifications(*explicit_pack_names).map { new(_1) }
    end

    # We assume that both `patchy` and all component packs are loaded in Bundler group `:development`
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
      Dir['**/', base: @pack_path.to_s]
        .select { |relative_path| relative_path.match? %r(_[^/]+_/\z) }
        .map { |relative_path| Component.new_or_nil(relative_path, pack: self) }
        .compact
    end
  end
end
