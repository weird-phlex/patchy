# frozen_string_literal: true

module WeirdPhlex
  class ComponentPack
    class Config < ::WeirdPhlex::Config

      attr_reader :component_pack_root

      def initialize(root_path)
        @component_pack_root = root_path.join('pack')
        super()
      end

      private

      def config_path
        component_pack_root.join('.weird_phlex_pack.yml')
      end

      def error_message_header
        "Invalid configuration detected in component pack's `.weird_phlex_pack.yml` file!"
      end

      def json_schema
        {
          'type' => 'object',
          'additionalProperties' => false,
          'properties' => {
            'setup' => {
              'type' => 'object',
              'properties' => {
                'dependencies' => {
                  'type' => 'array',
                  'items' => {
                    'type' => 'string',
                  },
                },
                'hooks' => {
                  'type' => 'object',
                  'additionalProperties' => { # hook name
                    'type' => 'array',
                    'items' => {
                      'type' => 'string',
                    },
                  },
                },
                'custom_rake_task' => {
                  'type' => 'string',
                },
                'additional_instructions' => {
                  'type' => 'string',
                },
              },
            },
            'dependencies' => {
              'type' => 'object',
              'additionalProperties' => { # component name
                'type' => 'array',
                'items' => {
                  'type' => 'string',
                },
              },
            },
            'parts' => {
              'type' => 'object',
              'additionalProperties' => false,
              'properties' => {
                'components' => string_mapping_schema,
                'shared' => string_mapping_schema,
                'global' => string_mapping_schema,
              },
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
