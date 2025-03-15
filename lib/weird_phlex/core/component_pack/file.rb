# frozen_string_literal: true

module WeirdPhlex
  module Core
    module ComponentPack
      class File
        attr_reader :component, :part, :file, :raw_file

        def initialize(path, component_path:)
          @path = path
          @raw_file = path
          @component_path = component_path
          @relative_path = @path.to_s.delete_prefix("#{@component_path}/")
          split = @relative_path.split('/')

          if split.first == 'version.rb'
            @ignored = true
            @shared_file = false
            @component = nil
            @part = nil
            @file = nil
          elsif split.first == 'shared'
            @shared_file = true
            @component = nil
            @part = nil
            @file = nil
          elsif (matches = @relative_path.match(%r{\A(?<component>.*_component)/(?<part>[^/]*)/(?<file>.*)}))
            @shared_file = false
            @component = matches[:component]
            @part = matches[:part]
            @file = matches[:file]
          else
            raise "Regex error: could not parse file '#{@path}'"
          end
        end

        def ignored?
          !!@ignored
        end

        def shared?
          !@ignored && !!@shared_file
        end

        def component_file?
          !@ignored && !@shared_file && @component.present?
        end

        def to_s
          if @ignored
            'IGNORED'
          elsif @shared_file
            "SHARED FILE: #{@relative_path}"
          else
            "FILE: #{@component} - #{@part} - #{@file}"
          end
        end
      end
    end
  end
end
