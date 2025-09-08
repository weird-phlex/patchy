# frozen_string_literal: true

require 'thor'

module Patchy
  class CLI < Thor
    class_option :help, type: :boolean, aliases: 'h', desc: 'Display help for a command'
    map 'g' => :generate, 'a' => :generate, 'add' => :generate

    desc 'generate [ARGS]', 'Add selected components to your application. Add all with `-a/--all`'
    def generate(*args)
      Patchy::Main.generate(args)
    end

    def self.exit_on_failure?
      true
    end
  end
end
