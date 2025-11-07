# frozen_string_literal: true

module Yard
  module Lint
    module Validators
      module Warnings
        module UnknownParameterName
          # Result object for UnknownParameterName validation
          class Result < Results::Base
            self.default_severity = 'error'
            self.offense_type = 'line'
            self.offense_name = 'UnknownParameterName'

            # Build human-readable message for UnknownParameterName offense
            # @param offense [Hash] offense data with :message key
            # @return [String] formatted message
            def build_message(offense)
              offense[:message] || 'UnknownParameterName detected'
            end
          end
        end
      end
    end
  end
end
