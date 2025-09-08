# frozen_string_literal: true

require 'yaml'
require 'json_schemer'

module Patchy
  class Config
    attr_reader :config

    def initialize
      load!
    end

    private

    def load!
      config = YAML.safe_load_file(config_path, symbolize_names: false)
      validator = JSONSchemer.schema(json_schema)

      if validator.valid? config
        @config = config
      else
        errors = validator.validate config

        puts <<~STRING
          #{error_message_header}

          Errors:
          #{errors.to_a.map { "- #{_1['error']}" }.join("\n")}

          Expected schema:
          #{JSON.pretty_generate(json_schema)}
        STRING

        exit(1)
      end
    end
  end

  def config_path
    raise 'Not implemented!'
  end

  def json_schema
    raise 'Not implemented!'
  end

  def error_message_header
    'Invalid configuration detected!'
  end
end
