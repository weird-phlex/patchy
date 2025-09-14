# frozen_string_literal: true

require 'thor'

module Patchy
  class CLI < Thor
    class_option :help, type: :boolean, aliases: 'h', desc: 'Display help for a command'
    map 'g' => :generate, 'a' => :generate, 'add' => :generate

    desc 'generate [ARGS]', 'Add selected components to your application. Add components selectively by specifying glob patterns, e.g. `ruby_ui/*`.'
    def generate(*args)
      if args.none?
        Patchy::Main.add('*/*')
      else
        Patchy::Main.add(*args)
      end
    end

    def self.exit_on_failure?
      true
    end
  end
end
