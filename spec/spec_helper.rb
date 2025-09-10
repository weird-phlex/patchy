# frozen_string_literal: true

begin
  require 'debug' unless ENV['CI']
rescue LoadError
  # no-op
end

ENV['RAILS_ENV'] = 'test'

require 'open3'
require 'patchy'

require 'zeitwerk'
support_loader = Zeitwerk::Loader.new
support_loader.tag = 'spec'
support_loader.push_dir("#{__dir__}/support")
support_loader.ignore("#{__dir__}/support/rspec")
support_loader.setup

Dir["#{File.dirname(__FILE__)}/support/rspec/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.example_status_persistence_file_path = 'tmp/rspec_examples.txt'
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.order = :random
  Kernel.srand config.seed
end
