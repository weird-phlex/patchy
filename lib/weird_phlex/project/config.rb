# frozen_string_literal: true

require 'yaml'
require 'json_schemer'

module WeirdPhlex
  module Project
    class Config < ::WeirdPhlex::Config

      def part_path(part_name)
        config.dig('part_paths', part_name.to_s)
      end

      def shared_part_path(shared_part_name)
        config.dig('shared_paths', shared_part_name.to_s)
      end

      private

      def config_path
        project_root.join('.weird_phlex.yml')
      end

      # A bit naive, copied from File
      def project_root
        Pathname.new(Dir.pwd)
      end

      def error_message_header
        "Invalid configuration detected in project's `.weird_phlex.yml` file!"
      end

      def json_schema
        {
          'type' => 'object',
          'additionalProperties' => false,
          'properties' => {
            'part_paths' => {
              'type' => 'object',
              'additionalProperties' => {
                'type' => 'string',
              },
            },
            'shared_paths' => {
              'type' => 'object',
              'additionalProperties' => {
                'type' => 'string',
              },
            },
          },
        }
      end
    end
  end
end
