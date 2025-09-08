# frozen_string_literal: true

require 'patchy/project/component'
require 'patchy/project/config'
require 'patchy/project/file'
require 'patchy/project/target_file'

module Patchy
  class Project
    attr_reader :config, :root_path

    def initialize
      # very naive, assumes binary is run from Rails root
      @root_path = Pathname.new(Dir.pwd)
      @config = Config.new
    end

    def all_files
      File.all
    end

    def all_components
      Component.all
    end
  end
end
