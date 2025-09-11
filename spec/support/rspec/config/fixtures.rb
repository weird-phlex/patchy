require 'tmpdir'

RSpec.configure do |config|
  config.include(Test::Fixtures)

  config.around do |example|
    Dir.mktmpdir do |tmp_dir|
      example.metadata[:tmp_dir] = Pathname.new(tmp_dir)
      example.run
    end
  end

  config.before do |example|
    @tmp_dir = example.metadata[:tmp_dir]
  end
end
