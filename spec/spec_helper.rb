# frozen_string_literal: true

begin
  require 'debug' unless ENV['CI']
rescue LoadError
  # no-op
end

require 'open3'
require 'weird_phlex'

ENV['RAILS_ENV'] = 'test'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

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
