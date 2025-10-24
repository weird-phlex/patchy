# frozen_string_literal: true

if RUBY_VERSION < '3.2'
  require 'polyfill-data'
end

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect('cli' => 'CLI')
loader.setup

require 'active_support/all'

# Optionally:
# loader.eager_load
