# frozen_string_literal: true

require 'weird_phlex/project/file'

module WeirdPhlex
  class Project
    class Component
      attr_reader :files

      # Probably not correct. We might not want to group files from different libraries
      # and variants (inconsistent state) together.
      def self.all
        WeirdPhlex::Project::File.all
          .select(&:component_file?)
          .group_by(&:component)
          .map { |component_name, files| new(component_name, files: files) }
      end

      def initialize(name, files: [])
        @name = name
        @files = files
      end

      def to_s
        "#{@name} - #{@files.count} file#{'s' if @files.count != 1}"
      end
    end
  end
end
