# frozen_string_literal: true

require "ostruct"

TMP_PROJECTS_FOLDER = WeirdPhlex.root.join('tmp/projects').freeze
TMP_PACKS_FOLDER   = WeirdPhlex.root.join('tmp/packs').freeze
PROJECTS_FOLDER    = WeirdPhlex.root.join('spec/fixtures/projects').freeze
PACKS_FOLDER       = WeirdPhlex.root.join('spec/fixtures/packs').freeze
COMPONENTS_FOLDER  = WeirdPhlex.root.join('spec/fixtures/components').freeze

class Pack
  attr_reader :pack_name

  def initialize(pack_name)
    @pack_name = pack_name
  end

  def with_component(component)
    components_path.mkpath
    FileUtils.cp_r(
      COMPONENTS_FOLDER.join(component),
      components_path,
    )
  end

  def pack_path
    @pack_path ||= TMP_PACKS_FOLDER.join(pack_name)
  end

  def components_path
    @components_path ||= pack_path.join("pack/components")
  end

  def gemspec
    gemspec_path = PACKS_FOLDER.join("#{pack_path}/#{pack_name}.gemspec").to_s
    gemspec = Gem::Specification.load(gemspec_path)
    # needed so that #gem_dir method does not return a
    # path with version number.
    gemspec.source = OpenStruct.new(root: TMP_PACKS_FOLDER.join(pack_name).to_s)
    gemspec
  end
end

def with_project(project)
  TMP_PROJECTS_FOLDER.mkpath
  FileUtils.cp_r(
    PROJECTS_FOLDER.join(project),
    TMP_PROJECTS_FOLDER.join(project),
  )
end

def with_pack(pack_name)
  TMP_PACKS_FOLDER.mkpath
  FileUtils.cp_r(
    PACKS_FOLDER.join(pack_name),
    TMP_PACKS_FOLDER.join(pack_name),
  )

  pack = Pack.new(pack_name)

  loaded_specs = Gem.loaded_specs.merge({ pack_name => pack.gemspec })

  allow(Gem).to receive(:loaded_specs).and_return loaded_specs

  yield(pack)
end

def within_project(project, &block)
  Dir.chdir(TMP_PROJECTS_FOLDER.join(project), &block)
end

def remove_tmp_folders
  [TMP_PROJECTS_FOLDER, TMP_PACKS_FOLDER].each do |folder|
    next unless folder.exist?

    folder.rmtree
  end
end

RSpec.configure do |config|
  config.before(:suite) { remove_tmp_folders }

  config.after { remove_tmp_folders }
end
