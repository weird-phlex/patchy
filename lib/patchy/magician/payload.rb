require 'json_schemer'

module Patchy
  class Magician
    Payload = Data.define(:pack, :type, :component, :part, :file, :version, :mode) do

      class_attribute :defaults, :hardcoded
      self.defaults = { 'mode' => 'patch' }.freeze
      self.hardcoded = { 'v' => 1 }.freeze

      private_class_method :new

      def self.from_json(data)
        validator = JSONSchemer.schema(json_schema)
        raise PayloadError, 'Payload data schema mismatch' unless validator.valid? data

        new(**data.except(*hardcoded.keys).symbolize_keys)
      end

      def self.from_data(data)
        data = data.stringify_keys
        raise PayloadError, 'Tried to override hardcoded key' if hardcoded.keys.intersect?(data.keys)
        data = { **defaults, **data, **hardcoded }

        validator = JSONSchemer.schema(json_schema)
        raise PayloadError, 'Payload data schema mismatch' unless validator.valid? data

        new(**data.except(*hardcoded.keys).symbolize_keys)
      end

      def serialize
        deconstruct_keys(nil).merge(self.class.hardcoded).symbolize_keys
      end

      def to_json(*)
        serialize.to_json(*)
      end

      def self.json_schema
        {
          'type' => 'object',
          'additionalProperties' => false,
          'properties' => {
            'pack' => {
              'type' => 'string',
            },
            'type' => {
              'type' => 'string',
              'enum' => [
                'components',
                'shared',
                'global',
              ],
            },
            'component' => {
              'type' => 'string',
            },
            'part' => {
              'type' => 'string',
            },
            'file' => {
              'type' => 'string',
            },
            'version' => {
              'type' => 'integer', # maybe commit hash instead
            },
            'mode' => {
              'type' => 'string',
              'enum' => [
                'patch',
                'replace',
                'ejected',
              ],
            },
            'v' => {
              'type' => 'integer',
              'description' => 'Payload version',
              'minimum' => hardcoded['v'],
              'maximum' => hardcoded['v'],
            },
          },
        }
      end

    end
  end
end
