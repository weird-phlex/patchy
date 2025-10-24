module Patchy
  class Magician
    class Analyzer

      attr_reader :file

      def initialize(file)
        @file = file
      end

      def analyze
        file_type = detect_file_type(file)

        FileAnalysis.new(
          comment_patterns: comment_patterns(file_type),
          shebang: shebang?(file_type),
          custom_payload_proc: custom_payload_proc(file_type),
        )
      end

      private

      def shebang?(file_type)
        case file_type
        when :shell_script, :ruby_script, :js_script
          true
        else
          false
        end
      end

      def comment_patterns(file_type)
        case file_type
        when :ruby, :ruby_script, :shell_script, :cucumber, :yaml
          ['#']
        when :erb, :thor
          ['<%-', '<%#']
        when :html
          ['<!--']
        when :haml
          ['-#']
        when :css, :sass
          ['/*']
        when :js, :ts, :js_script
          ['//']
        else
          ['#']
        end
      end

      def custom_payload_proc(file_type)
        case file_type
        when :erb, :thor
          ->(data) { "<%- patchy: #{data} -%>\n" }
        when :html
          ->(data) { "<!-- patchy: #{data} -->\n" }
        when :css, :sass
          ->(data) { "/* patchy: #{data} */\n" }
        end
      end

      def detect_file_type(file)
        case extension(file)
        when /\.rb$/, /\.rake$/
          detect_script_type(file) || :ruby
        when /\.tt$/
          :thor
        when /\.html$/
          :html
        when /\.erb$/, /\.herb$/
          :erb
        when /\.haml$/
          :haml
        when /\.css$/
          :css
        when /\.scss$/, /\.sass$/
          :sass
        when /\.feature$/
          :cucumber
        when /\.js$/, /\.jsx$/, /\.cjs$/, /\.mjs$/
          detect_script_type(file) || :js
        when /\.ts$/, /\.tsx/
          detect_script_type(file) || :ts
        when /\.yml$/
          :yaml
        when /\.sh$/, ''
          detect_script_type(file) || raise("Unsupported file type: #{extension(file)}")
        else
          raise("Unsupported file type: #{extension(file)}")
        end
      end

      def detect_script_type(file)
        case read_beginning(file).lines.first
        when /^#!.*sh/
          :shell_script
        when /^#!.*ruby/
          :ruby_script
        when /^#!.*node/
          :js_script
        end
      end

      def extension(file)
        file.basename.to_s.delete_prefix('.').match(/(\..*)$/)
        Regexp.last_match(1) || ''
      end

      def read_beginning(file)
        bytes = file.read(2_000)
        if bytes
          bytes.force_encoding('UTF-8').encode('UTF-8', undef: :replace, invalid: :replace, replace: '?')
        else
          ''
        end
      end

    end
  end
end
