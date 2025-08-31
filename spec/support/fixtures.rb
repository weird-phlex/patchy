# frozen_string_literal: true

TMP_FOLDER=WeirdPhlex.root.join('tmp/projects').freeze
PROJECTS_FOLDER=WeirdPhlex.root.join('spec/fixtures/projects').freeze
PACKS_FOLDER=WeirdPhlex.root.join('spec/fixtures/packs').freeze

def setup_fixtures(project, *component_packs)
  TMP_FOLDER.mkpath
  FileUtils.cp_r(
    PROJECTS_FOLDER.join(project),
    TMP_FOLDER.join(project)
  )

  loaded_specs = component_packs.reduce(Gem.loaded_specs.dup) do |hash, component_pack|
    gemspec_path = PACKS_FOLDER.join("#{component_pack}/#{component_pack}.gemspec").to_s
    gemspec = Gem::Specification.load(gemspec_path)
    # needed so that #gem_dir method does not return a
    # path with version number.
    gemspec.source = double(root: PACKS_FOLDER.join(component_pack).to_s)

    hash.merge!({ component_pack => Gem::Specification.load(gemspec_path) })
  end

  allow(Gem).to receive(:loaded_specs).and_return loaded_specs
end

def within_project(project, &block)
  Dir.chdir(TMP_FOLDER.join(project), &block)
end

RSpec.configure do |config|
  config.before :suite do
    next unless TMP_FOLDER.exist?

    TMP_FOLDER.rmtree
  end

  config.after do
    next unless TMP_FOLDER.exist?

    TMP_FOLDER.rmtree
  end
end
