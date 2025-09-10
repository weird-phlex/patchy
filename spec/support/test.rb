class Test
  ROOT = Pathname.new(File.dirname(__dir__)).freeze

  PROJECTS_FOLDER = ROOT.join('fixtures/projects').freeze
  PACKS_FOLDER = ROOT.join('fixtures/packs').freeze
  COMPONENTS_FOLDER = ROOT.join('fixtures/components').freeze

  def self.root
    ROOT
  end
end
