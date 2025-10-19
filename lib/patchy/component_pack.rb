# frozen_string_literal: true

module Patchy
  class ComponentPack
    IMPLICIT_PACK_REGEX = /\Apatchy_pack-(?<pack_name>.+)\Z/

    attr_reader :config, :name, :root_path, :pack_path

    def initialize(name:, root_path:)
      @name = name
      @root_path = Pathname.new(root_path)
      @pack_path = @root_path.join('pack')
      @config = Config.new(@root_path)
    end

    def self.all(*_explicit_pack_names)
      self::DirectoryPack.all +
        self::GemPack.all
    end

    def components
      Dir['**/', base: @pack_path.to_s]
        .select { |relative_path| relative_path.match? %r(_[^/]+_/\z) }
        .map { |relative_path| Component.new_or_nil(relative_path, pack: self) }
        .compact
    end
  end
end
