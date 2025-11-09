# frozen_string_literal: true

module Yard
  module Lint
    module Validators
      module Documentation
        module UndocumentedOptions
          # Configuration for the UndocumentedOptions validator
          class Config < Configs::Base
            # Default configuration values for UndocumentedOptions
            # @return [Hash] default settings
            self.defaults = {
              'Enabled' => true,
              'Severity' => 'warning',
              'Description' => 'Detects methods with options hash parameters but no @option tags.'
            }.freeze
          end
        end
      end
    end
  end
end
