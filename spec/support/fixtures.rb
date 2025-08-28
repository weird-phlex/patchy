# frozen_string_literal: true

TMP_FOLDER=WeirdPhlex.root.join('tmp/projects').freeze

def setup_fixtures(project, *component_packs)
  TMP_FOLDER.mkpath
  FileUtils.cp_r(
    WeirdPhlex.root.join("spec/fixtures/#{project}/"),
    TMP_FOLDER.join(project),
  )

  component_packs.each do |component_pack|
    TMP_FOLDER.join("#{project}/Gemfile").write(
      "gem '#{component_pack}', path: '#{WeirdPhlex.root.join("spec/fixtures/#{component_pack}")}'",
      mode: 'a+',
    )
  end

  fixture_command(project, 'bundle check || bundle --force')
end

def fixture_command(project, command)
  project_path = TMP_FOLDER.join(project)

  system("cd #{project_path} && BUNDLE_GEMFILE=#{project_path}/Gemfile #{command}", exception: true)
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
