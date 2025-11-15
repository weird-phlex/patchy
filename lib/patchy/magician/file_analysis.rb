module Patchy
  class Magician
    class FileAnalysis
      Comment = Data.define(:open, :close) do
        def wrap(string)
          "#{open} #{string} #{close}".strip
        end
      end

      attr_reader :file, :file_type

      def initialize(file)
        @file = file
        @file_type = detect_file_type(file)
      end

      def shebang?
        case file_type
        when :shell_script, :ruby_script, :js_script
          true
        else
          false
        end
      end

      def magic_comment_regex
        Regexp.new("^\s*#{[comment, *additional_comments].map { Regexp.escape(_1.open) }.join('|')}")
      end

      def payload_regex
        Regexp.new("\s*#{Regexp.escape(comment.open)}\s*patchy:\s*({.*})")
      end

      def payload_proc
        ->(data) { comment.wrap("patchy: #{data}").concat("\n") }
      end

      private

      def comment
        case file_type
        when :ruby, :ruby_script, :shell_script, :cucumber, :yaml
          Comment.new(open: '#', close: nil)
        when :erb, :thor
          Comment.new(open: '<%-', close: '-%>')
        when :html
          Comment.new(open: '<!--', close: '-->')
        when :haml
          Comment.new(open: '-#', close: nil)
        when :slim
          Comment.new(open: '/', close: nil)
        when :css, :sass
          Comment.new(open: '/*', close: '*/')
        when :js, :ts, :js_script
          Comment.new(open: '//', close: nil)
        else
          Comment.new(open: '#', close: nil)
        end
      end

      def additional_comments
        case file_type
        when :erb, :thor
          [Comment.new(open: '<%#', close: '%>')]
        else
          []
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
        when /\.slim$/
          :slim
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
        when /\.yml$/, /\.yaml$/
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
