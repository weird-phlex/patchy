# frozen_string_literal: true

require 'weird_phlex/project/component'
require 'weird_phlex/project/config'
require 'weird_phlex/project/file'
require 'weird_phlex/project/target_file'

module WeirdPhlex
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
