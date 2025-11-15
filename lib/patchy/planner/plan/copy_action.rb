# frozen_string_literal: true

module Patchy
  class Planner
    class Plan
      class CopyAction
        def initialize(source_file, target_file)
          @source_file = source_file
          @target_file = target_file
        end

        def perform!
          magician = Magician.new(regular_path: @source_file.raw_file, magic_path: @target_file.raw_file)

          payload = Magician::Payload.from_data(
            {
              pack: @source_file.component.pack.name, # short name should be sufficient
              type: @source_file.component.type.to_s, # components | shared | global
              component: @source_file.component.canonical_name_without_type, # including outer directories
              part: @source_file.part, # differentiate between files, if shallow placement is chosen
              file: @source_file.file,
              version: 1, # maybe commit hash instead
              mode: 'patch', # patch, replace, ejected
            },
          )

          magician.write(payload)
        end

        def to_s
          <<~HEREDOC
            COPY:
              #{@source_file}
              #{@target_file}
          HEREDOC
        end
      end
    end
  end
end
