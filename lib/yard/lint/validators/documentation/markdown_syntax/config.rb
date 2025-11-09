# frozen_string_literal: true

module Yard
  module Lint
    module Validators
      module Documentation
        module MarkdownSyntax
          # Configuration for the MarkdownSyntax validator
          class Config < Configs::Base
            # Default configuration values for MarkdownSyntax
            # @return [Hash] default settings
            self.defaults = {
              'Enabled' => true,
              'Severity' => 'warning',
              'Description' => 'Detects common markdown syntax errors in documentation.'
            }.freeze
          end
        end
      end
    end
  end
end
