# frozen_string_literal: true

require_relative "lib/patchy_pack/example/version"

Gem::Specification.new do |s|
  s.name = "without-prefix"
  s.version = PatchyPack::Example::VERSION
  s.authors = ["Klaus Weidinger"]
  s.email = ["Klaus Weidinger"]
  s.homepage = "https://github.com/weird-phlex/patchy_pack-example"
  s.summary = "Example description"
  s.description = "Example description"

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/weird-phlex/patchy_pack-example/issues",
    "changelog_uri" => "https://github.com/weird-phlex/patchy_pack-example/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://github.com/weird-phlex/patchy_pack-example",
    "homepage_uri" => "https://github.com/weird-phlex/patchy_pack-example",
    "source_code_uri" => "https://github.com/weird-phlex/patchy_pack-example",
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
