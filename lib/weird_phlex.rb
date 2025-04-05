# frozen_string_literal: true

require 'weird_phlex/version'
require 'weird_phlex/railtie' if defined?(Rails::Railtie)

require 'active_support/all'

require 'weird_phlex/config'

require 'weird_phlex/project'
require 'weird_phlex/component_pack'

require 'weird_phlex/planner'
require 'weird_phlex/main'
require 'weird_phlex/cli'
