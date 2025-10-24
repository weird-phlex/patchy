module Patchy
  class Magician
    attr_reader :path, :broken_data

    def initialize(path)
      @path = case path
      when Pathname
        path
      when String
        Pathname.new(path)
      end
    end

    # TODO: parse data full and return Data object
    def read
      patchy_hash
    end

    # TODO: Should also be true, if JSON can't be parsed or is incomplete
    def magic?
      patchy_hash.present?
    end

    def clean!
      # TODO: implement
    end

    def write!(data)
      # Other data sources not yet supported
      raise unless data.is_a? Patchy::ComponentPack::File

      source_file = data

      magic_comment_data = {
        pack: source_file.component.pack.name, # short name should be sufficient
        type: source_file.component.type, # component | shared | global
        component: source_file.component.name, # including outer directories
        part: source_file.part, # differentiate between files, if shallow placement is chosen
        file: source_file.file,
        version: 1,
        mode: 'patch', # patch, replace, ejected
      }

      # TODO: depends on file extension
      path.write <<~FILE
        # patchy: #{magic_comment_data.to_json}
        #{path.read}
      FILE

      nil
    end

    private

    def read_beginning
      bytes = path.read(2_000)
      if bytes
        bytes.force_encoding('UTF-8').encode('UTF-8', undef: :replace, invalid: :replace, replace: '?')
      else
        ''
      end
    end

    def extension
      path.basename.to_s.delete_prefix('.').match(/(\..*)$/)
      Regexp.last_match(1) || ''
    end

    def magic_comments
      read_beginning.lines.take_while { _1.start_with?(%r{(#|//|<%#|/\*|<!--|-#)}) }
    end

    def patchy_hash
      return unless magic_comments.any? { _1.match(/patchy: ({.*})/) }

      begin
        JSON.parse(Regexp.last_match(1))
      rescue JSON::ParserError
        @broken_data = Regexp.last_match(1)
        nil
      end
    end

  end
end
