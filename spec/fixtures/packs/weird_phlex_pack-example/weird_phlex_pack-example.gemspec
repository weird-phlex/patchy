# frozen_string_literal: true

require_relative "lib/weird_phlex_pack/dev_component_pack/testing/version"

Gem::Specification.new do |s|
  s.name = "weird_phlex_pack-example"
  s.version = WeirdPhlexPack::DevComponentPack::Testing::VERSION
  s.authors = ["Klaus Weidinger"]
  s.email = ["Klaus Weidinger"]
  s.homepage = "https://github.com/weird-phlex/weird_phlex-dev_component_pack-testing"
  s.summary = "Example description"
  s.description = "Example description"

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/weird-phlex/weird_phlex-dev_component_pack-testing/issues",
    "changelog_uri" => "https://github.com/weird-phlex/weird_phlex-dev_component_pack-testing/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://github.com/weird-phlex/weird_phlex-dev_component_pack-testing",
    "homepage_uri" => "https://github.com/weird-phlex/weird_phlex-dev_component_pack-testing",
    "source_code_uri" => "https://github.com/weird-phlex/weird_phlex-dev_component_pack-testing",
'rubygems_mfa_required' => 'true',
  }

  s.license = "MIT"

  s.files = Dir.glob("lib/**/*") + Dir.glob("bin/**/*") + %w[README.md LICENSE.txt CHANGELOG.md]
  s.require_paths = ["lib"]
  s.required_ruby_version = ">= 3.1"

  s.add_development_dependency "bundler", ">= 1.15"
  s.add_development_dependency "rake", ">= 13.0"
  s.add_development_dependency "rspec", ">= 3.9"
end
