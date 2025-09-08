# frozen_string_literal: true

require 'patchy/version'
require 'patchy/railtie' if defined?(Rails::Railtie)

require 'active_support/all'

require 'patchy/config'

require 'patchy/project'
require 'patchy/component_pack'

require 'patchy/planner'
require 'patchy/main'
require 'patchy/cli'

module Patchy
  def self.root
    Pathname.new(File.dirname(__dir__))
  end
end
