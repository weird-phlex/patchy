class Test
  ROOT = Pathname.new(File.dirname(__dir__)).freeze

  def self.root
    ROOT
  end

  def self.project_fixture(name)
    ROOT.join('fixtures', 'projects', name)
  end

  def self.pack_fixture(name)
    ROOT.join('fixtures', 'packs', name)
  end

  def self.component_fixture(name)
    ROOT.join('fixtures', 'components', name)
  end
end
