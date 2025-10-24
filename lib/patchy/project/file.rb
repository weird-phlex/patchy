# frozen_string_literal: true

module Patchy
  class Project
    class File
      LIBRARAY_AND_VARIANT_REGEX = %r{\A(?<library>[^/]+)/(?<variant>[^/]+)/(?<component_pack_path>.*)\Z}

      attr_reader :file, :component, :raw_file

      def self.all
        paths = if directories.empty?
          files_in(project_root)
        else
          directories.flat_map do |dir|
            files_in(project_root.join(dir))
          end
        end
        paths.map { new(_1, project_path: project_root) }
      end

      def initialize(path, project_path:)
        @path = Pathname.new(path)
        @raw_file = @path
        @project_path = project_path
        @relative_project_path = @path.to_s.delete_prefix("#{@project_path}/")

        @data = patchy_hash

        if @data.nil?
          @ignored = true
          @library = nil
          @variant = nil
          @shared_file = false
          @component = nil
          @part = nil
          @file = nil
          return
        end

        @version = @data['version']
        @relative_path = @data['path']

        if (matches = @relative_path.match(LIBRARAY_AND_VARIANT_REGEX))
          @library = matches[:library]
          @variant = matches[:variant]
          @component_pack_path = matches[:component_pack_path]
        else
          @broken_data = @data.to_json
          return
        end

        split = @component_pack_path.split('/')

        if split.first == 'shared'
          @shared_file = true
          @component = nil
          @part = nil
          @file = nil
        elsif (matches = @component_pack_path.match(%r{\A(?<component>.*_component)/(?<part>[^/]*)/(?<file>.*)}))
          @shared_file = false
          @component = matches[:component]
          @part = matches[:part]
          @file = matches[:file]
        else
          raise "Regex error: could not parse file '#{@path}'"
        end
      end

      def component_file?
        patchy_hash.present? && !@shared_file && @component.present?
      end

      def patchy_file?
        component_file? || @broken_data
      end

      def to_s
        if @broken_data
          "BROKEN DATA: #{@broken_data}"
        elsif component_file?
          if @shared_file
            "SHARED FILE: #{@component_pack_path}"
          else
            "FILE: #{@component} - #{@part} - #{@file}"
          end
        else
          'IGNORED'
        end
      end

      def patchy_hash
        magician = Magician.new(@raw_file)
        data = magician.read
        if data.nil?
          @broken_data = magician.broken_data
        end
        data
      end

      class << self
        private

        # probably needs to be configurable, maybe with presets for Rails, Hanami, Middleman, e.g.
        def directories
          %w[app config lib public test vendor]
        end

        # A bit naive
        def project_root
          Pathname.new(Dir.pwd)
        end

        def files_in(root)
          Dir['**/*', base: root.to_s].map { root.join(_1) }.select(&:file?)
        end
      end
    end
  end
end
