# frozen_string_literal: true

require 'yaml'

module WeirdPhlex
  module Project
    class Config
      attr_reader :config

      def initialize
        config_path = project_root.join('.weird_phlex.yml')
        @config = YAML.safe_load_file(config_path, symbolize_names: true)
      end

      def part_path(part_name)
        config.dig(:part_paths, part_name.to_sym)
      end

      def shared_part_path(shared_part_name)
        config.dig(:shared_paths, shared_part_name.to_sym)
      end

      # A bit naive, copied from File
      def project_root
        Pathname.new(Dir.pwd)
      end
    end
  end
end
