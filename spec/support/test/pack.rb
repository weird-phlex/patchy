class Test::Pack
  Source = Struct.new(:root)

  attr_reader :pack_name, :pack_path, :components_path

  def initialize(pack_name, dir:)
    @pack_name = pack_name
    @pack_path = dir.join(pack_name)
    @components_path = @pack_path.join('pack', 'components')
  end

  def with_component(component)
    components_path.mkpath
    FileUtils.cp_r(
      Test.component_fixture(component),
      components_path,
    )
  end

  def gemspec
    gemspec_path = pack_path.join("#{pack_name}.gemspec").to_s
    gemspec = Gem::Specification.load(gemspec_path)
    # Needed so that #gem_dir method does not return a
    # path with version number.
    gemspec.source = Source.new(pack_path)
    gemspec
  end
end
