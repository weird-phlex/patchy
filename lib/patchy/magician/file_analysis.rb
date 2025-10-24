module Patchy
  class Magician
    FileAnalysis = Data.define(:comment_patterns, :shebang, :custom_payload_proc) do

      def initialize(comment_patterns:, shebang:, custom_payload_proc: nil)
        super
      end

      def shebang?
        !!shebang
      end

      def magic_comment_regex
        Regexp.new("^\s*#{comment_patterns.map { Regexp.escape(_1) }.join('|')}")
      end

      def payload_regex
        Regexp.new("\s*#{Regexp.escape(comment_patterns.first)}\s*patchy:\s*({.*})")
      end

      def payload_proc
        custom_payload_proc || ->(data) { "#{comment_patterns.first} patchy: #{data}\n" }
      end

    end
  end
end
