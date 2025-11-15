require 'fileutils'

module Patchy
  class Magician
    # Handles magic comments

    # DEFINITIONS:
    # Magic comments:
    # - Comments at the top of a file.
    # - Starting after the shebang (#!), if that is present.
    # - Continuing until the first non-comment line is found.

    class SpellFizzled < StandardError; end # developer errors
    class PayloadError < StandardError; end

    attr_reader :regular_path, :magic_path
    attr_accessor :analysis

    def initialize(magic_path:, regular_path: nil)
      @regular_path = to_pathname(regular_path)
      @magic_path = to_pathname(magic_path)
    end

    def magic?
      raise SpellFizzled, 'No file to examine!' unless magic_path && magic_path.exist?

      self.analysis = FileAnalysis.new(magic_path)

      magic_comments(magic_path).any? { _1.match(analysis.payload_regex) }
    end

    def read!
      raise SpellFizzled, 'No file to read from!' unless magic_path && magic_path.exist?

      self.analysis = FileAnalysis.new(magic_path)

      retrieve_payload!
    end

    def read
      read!
    rescue JSON::ParserError, PayloadError
      nil
    end

    def clean!
      raise SpellFizzled, 'No file to clean!' unless magic_path && magic_path.exist?
      raise SpellFizzled, 'No file to store cleaned output to!' unless regular_path

      self.analysis = FileAnalysis.new(magic_path)

      touch!(regular_path)

      @skip_shebang = analysis.shebang?
      @end_of_magic_comments_reached = false

      regular_path.open('w') do |output|
        magic_path.each_line do |line|
          if !@end_of_magic_comments_reached
            if @skip_shebang
              output.write(line)
              @skip_shebang = false
            elsif line.match(analysis.payload_regex)
              # Found our patchy data. Don't copy it to the output.
              next
            else
              output.write(line)
              if !line.start_with?(analysis.magic_comment_regex)
                @end_of_magic_comments_reached = true
              end
            end
          else
            output.write(line)
          end
        end
      end

      retrieve_payload!
    end

    def clean
      clean!
    rescue JSON::ParserError, PayloadError
      nil
    end

    def write(payload)
      raise SpellFizzled, 'No file to write to!' unless regular_path && regular_path.exist?
      raise SpellFizzled, 'No file to store written output to!' unless magic_path
      raise SpellFizzled, 'Please provide Payload object!' unless payload.is_a?(Payload)

      self.analysis = FileAnalysis.new(regular_path)

      touch!(magic_path)

      input_size = regular_path.size
      if input_size == 0
        regular_path.write("\n")
      end

      @skip_shebang = analysis.shebang?
      @magic_comment_inserted = false

      magic_path.open('w') do |output|
        regular_path.each_line do |line|
          if !@magic_comment_inserted
            if @skip_shebang
              output.write(line)
              @skip_shebang = false
            else
              output.write(analysis.payload_proc.call(payload.to_json))
              @magic_comment_inserted = true
              output.write(line)
            end
          else
            output.write(line)
          end
        end
      end

      regular_path.truncate(input_size)

      nil
    end

    private

    def retrieve_payload!
      return unless magic_comments(magic_path).any? { _1.match(analysis.payload_regex) }

      Payload.from_json(JSON.parse(Regexp.last_match(1)))
    end

    def magic_comments(path)
      read_beginning(path)
        .lines
        .drop(analysis.shebang? ? 1 : 0)
        .take_while { _1.start_with?(analysis.magic_comment_regex) }
    end

    def read_beginning(path)
      bytes = path.read(2_000)
      if bytes
        bytes.force_encoding('UTF-8').encode('UTF-8', undef: :replace, invalid: :replace, replace: '?')
      else
        ''
      end
    end

    def to_pathname(path)
      case path
      when Pathname
        path
      when String
        Pathname.new(path)
      end
    end

    def touch!(pathname)
      FileUtils.mkdir_p(pathname.parent)
      FileUtils.touch(pathname)
    end

  end
end
