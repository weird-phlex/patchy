class Test::Project
  attr_reader :project_name, :project_path

  def initialize(project_name, dir:)
    @project_name = project_name
    @project_path = dir.join(project_name)
  end

  def config(&block)
    config_file = project_path.join('.patchy.yml')
    old_config = YAML.safe_load_file(config_file, symbolize_names: true)
    new_config = block.call(old_config)
    File.write(config_file, new_config.deep_stringify_keys.to_yaml)
  end
end
