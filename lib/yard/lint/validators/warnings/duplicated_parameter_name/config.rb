# frozen_string_literal: true

module Yard
  module Lint
    module Validators
      module Warnings
        module DuplicatedParameterName
          # Configuration for DuplicatedParameterName validator
          class Config < ::Yard::Lint::Validators::Config
            self.id = :duplicated_parameter_name
            self.defaults = {
              'Enabled' => true,
              'Severity' => 'error'
            }.freeze
          end
        end
      end
    end
  end
end
