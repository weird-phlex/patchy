class Test::Pack
  Source = Struct.new(:root)

  attr_reader :pack_name

  def initialize(pack_name, tmp_dir)
    @pack_name = pack_name
    @tmp_dir = tmp_dir
  end

  def with_component(component)
    components_path.mkpath
    FileUtils.cp_r(
      Test::COMPONENTS_FOLDER.join(component),
      components_path,
    )
  end

  def pack_path
    @pack_path ||= @tmp_dir.join(pack_name)
  end

  def components_path
    @components_path ||= pack_path.join("pack/components")
  end

  def gemspec
    gemspec_path = Test::PACKS_FOLDER.join("#{pack_path}/#{pack_name}.gemspec").to_s
    gemspec = Gem::Specification.load(gemspec_path)
    # needed so that #gem_dir method does not return a
    # path with version number.
    #
    gemspec.source = Source.new(@tmp_dir.join(pack_name))
    gemspec
  end
end
