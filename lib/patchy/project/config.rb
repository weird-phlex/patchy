# frozen_string_literal: true

module Patchy
  class Project
    class Config < ::Patchy::Config

      def part_path(component_type, part_name)
        part_config('main').dig(component_type.to_s, part_name.to_s)
      end

      private

      def part_config(namespace)
        config.dig('namespaces', namespace, 'parts')
      end

      def config_path
        project_root.join('.patchy.yml')
      end

      # A bit naive, copied from File
      def project_root
        Pathname.new(Dir.pwd)
      end

      def error_message_header
        "Invalid configuration detected in project's `.patchy.yml` file!"
      end

      def json_schema
        {
          'type' => 'object',
          'additionalProperties' => false,
          'properties' => {
            'component_packs' => {
              'oneOf' => [
                {
                  'type' => 'array',
                  'items' => {
                    'type' => 'string',
                  },
                },
                {
                  'type' => 'object',
                  'properties' => {
                    'include' => {
                      'type' => 'array',
                      'items' => {
                        'type' => 'string',
                      },
                    },
                    'exclude' => {
                      'type' => 'array',
                      'items' => {
                        'type' => 'string',
                      },
                    },
                  },
                },
              ],
            },
            'hooks' => {
              'type' => 'object',
              'additionalProperties' => { # hook name
                'type' => 'object',
              },
            },
            'namespaces' => {
              'type' => 'object',
              'additionalProperties' => { # namespace name
                'type' => 'object',
                'additionalProperties' => false,
                'properties' => {
                  'subdirectory' => {
                    'type' => 'string',
                  },
                  'packs' => pack_config_schema,
                  'parts' => part_config_schema,
                },
              },
            },
          },
        }
      end

      def part_config_schema
        {
          'type' => 'object',
          'additionalProperties' => false,
          'properties' => {
            'components' => string_mapping_schema,
            'shared' => string_mapping_schema,
            'global' => string_mapping_schema,
          },
        }
      end

      def pack_config_schema
        {
          'type' => 'array',
          'items' => {
            'type' => 'object',
            'additionalProperties' => false,
            'properties' => {
              'name' => 'string',
              'component_aliases' => string_mapping_schema,
            },
          },
        }
      end

      def string_mapping_schema
        {
          'type' => 'object',
          'additionalProperties' => {
            'type' => 'string',
          },
        }
      end
    end
  end
end
