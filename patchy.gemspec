# frozen_string_literal: true

require_relative 'lib/patchy/version'

Gem::Specification.new do |s|
  s.name = 'patchy'
  s.version = Patchy::VERSION
  s.authors = ['Klaus Weidinger']
  s.email = ['Klaus Weidinger']
  s.homepage = 'https://github.com/weird-phlex/patchy'
  s.summary = 'A package manager for "soft dependencies", mainly aimed at UI components'
  s.description = 'A package manager for "soft dependencies", mainly aimed at UI components'

  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/weird-phlex/patchy/issues',
    'changelog_uri' => 'https://github.com/weird-phlex/patchy/blob/master/CHANGELOG.md',
    'documentation_uri' => 'https://github.com/weird-phlex/patchy',
    'homepage_uri' => 'https://github.com/weird-phlex/patchy',
    'source_code_uri' => 'https://github.com/weird-phlex/patchy',
    'rubygems_mfa_required' => 'true',
  }

  s.license = 'MIT'

  s.files = Dir.glob('lib/**/*') + Dir.glob('bin/**/*') + %w[README.md LICENSE.txt CHANGELOG.md]
  s.require_paths = ['lib']
  s.bindir = 'bin'
  s.executables = ['patchy', 'pj']

  s.required_ruby_version = '>= 3.1'

  s.add_dependency 'thor', '~> 1.3'
  s.add_dependency 'activesupport'
  s.add_dependency 'json_schemer', '~> 2.4'
  s.add_dependency 'zeitwerk'

  s.add_development_dependency 'bundler', '>= 2.3.1'
  s.add_development_dependency 'rake', '>= 13.0'
  s.add_development_dependency 'rspec', '>= 3.9'
  s.add_development_dependency 'debug'
  s.add_development_dependency 'makandra-rubocop'
end
