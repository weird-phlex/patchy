# frozen_string_literal: true

module WeirdPhlex
  class Main
    class << self
      def generate(_args)
        WeirdPhlex::Planner.initial_full_installation_plan.perform!
      end

      def pack(name, args)
        puts "PACK: #{name}"
        puts args
      end
    end
  end
end
