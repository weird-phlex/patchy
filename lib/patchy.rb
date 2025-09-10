# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.inflector.inflect('cli' => 'CLI')
loader.setup # ready!

require 'active_support/all'

module Patchy
  def self.root
    Pathname.new(File.dirname(__dir__))
  end
end

# loader.eager_load # optionally
