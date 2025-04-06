# frozen_string_literal: true

require 'thor'

module WeirdPhlex
  class PackSubcommand < Thor
    class_option :help, type: :boolean, aliases: 'h', desc: 'Display help for a command'
    map 'g' => :generate, 'a' => :generate, 'add' => :generate

    def self.exit_on_failure?
      true
    end

    desc 'generate [ARGS]', 'Add selected components to your application. Add all with `-a/--all`'
    def pack(name, *args)
      ::WeirdPhlex::Main.pack(name, args)
    end

    default_task :pack

  end
end
