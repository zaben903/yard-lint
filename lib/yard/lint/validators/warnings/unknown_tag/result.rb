# frozen_string_literal: true

module Yard
  module Lint
    module Validators
      module Warnings
        module UnknownTag
          # Result object for unknown YARD tags validation
          class Result < Results::Base
            self.default_severity = 'error'
            self.offense_type = 'line'
            self.offense_name = 'UnknownTag'

            # Build human-readable message for unknown tag offense
            # @param offense [Hash] offense data with :message key
            # @return [String] formatted message
            def build_message(offense)
              offense[:message] || 'Unknown tag detected'
            end
          end
        end
      end
    end
  end
end
