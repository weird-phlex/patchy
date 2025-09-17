module Test::Fixtures
  def with_project(project_name)
    tmp_projects_dir.mkpath
    FileUtils.cp_r(
      Test.project_fixture(project_name),
      tmp_projects_dir.join(project_name),
    )

    return unless block_given?

    project = Test::Project.new(project_name, dir: tmp_projects_dir)
    yield(project)
  end

  def with_pack(pack_name)
    tmp_packs_dir.mkpath
    FileUtils.cp_r(
      Test.pack_fixture(pack_name),
      tmp_packs_dir.join(pack_name),
    )

    pack = Test::Pack.new(pack_name, dir: tmp_packs_dir)

    loaded_specs = Gem.loaded_specs.merge({ pack_name => pack.gemspec })
    allow(Gem).to receive(:loaded_specs).and_return loaded_specs

    yield(pack)
  end

  def within_project(project, &)
    Dir.chdir(tmp_projects_dir.join(project), &)
  end

  def tmp_projects_dir
    @tmp_dir.join('projects')
  end

  def tmp_packs_dir
    @tmp_dir.join('packs')
  end
end
