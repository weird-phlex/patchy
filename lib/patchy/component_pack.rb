# frozen_string_literal: true

module Patchy
  class ComponentPack
    IMPLICIT_PACK_REGEX = /\Apatchy_pack-(?<pack_name>.+)\Z/

    class DuplicatePacks < RuntimeError; end

    attr_reader :config, :name, :root_path, :pack_path

    def initialize(name:, root_path:)
      @name = name
      @root_path = Pathname.new(root_path)
      @pack_path = @root_path.join('pack')
      @config = Config.new(@root_path)
    end

    def components
      Dir['**/', base: @pack_path.to_s]
        .select { |relative_path| relative_path.match? %r(_[^/]+_/\z) }
        .map { |relative_path| Component.new_or_nil(relative_path, pack: self) }
        .compact
    end

    class << self
      def all(*_explicit_pack_names)
        packs = self::DirectoryPack.all + self::GemPack.all

        check_no_duplications(packs)

        packs
      end

      private

      def check_no_duplications(packs)
        packs.group_by(&:name).each do |name, packs_same_name|
          next if packs_same_name.size <= 1

          raise DuplicatePacks, "Duplicate packs are not allowed. There are #{packs_same_name.size} with the name #{name}."
        end
      end
    end
  end
end
