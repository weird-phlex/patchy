# frozen_string_literal: true

module Patchy
  class Project
    class Config < ::Patchy::Config
      GemPackConfig = Struct.new(:use_default_packs, :included, :excluded)
      DirectoryPackConfig = Struct.new(:included, :excluded)

      def part_path(component_type, part_name)
        part_config('main').dig(component_type.to_s, part_name.to_s)
      end

      def gem_pack_config
        case component_pack_config
        when nil
          GemPackConfig.new(true, [], [])
        when Array
          included = component_pack_config.select { gem_pack?(_1) }
          GemPackConfig.new(false, included, [])
        when Hash
          included = (component_pack_config['include'] || []).select { gem_pack?(_1) }
          excluded = (component_pack_config['exclude'] || []).select { gem_pack?(_1) }
          GemPackConfig.new(true, included, excluded)
        end
      end

      def directory_pack_config
        case component_pack_config
        when nil
          DirectoryPackConfig.new([], [])
        when Array
          included = component_pack_config.select { directory_pack?(_1) }
          DirectoryPackConfig.new(included, [])
        when Hash
          included = (component_pack_config['include'] || []).select { directory_pack?(_1) }
          excluded = (component_pack_config['exclude'] || []).select { directory_pack?(_1) }
          DirectoryPackConfig.new(included, excluded)
        end
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
              'anyOf' => [
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

      def component_pack_config
        config['component_packs']
      end

      def gem_pack?(string)
        !directory_pack?(string)
      end

      def directory_pack?(string)
        string.include?('/')
      end
    end
  end
end
