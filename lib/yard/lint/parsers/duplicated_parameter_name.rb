# frozen_string_literal: true

module Yard
  module Lint
    module Parsers
      # Class used to extract warnings details that are related to yard duplicated parameters
      # @example
      #   [warn]: @param tag has duplicate parameter name: auth_object
      #       in file `app/models/offense.rb' near line 27
      class DuplicatedParameterName < TwoLineBase
        # Set of regexps for detecting warnings reported by yard stats
        self.regexps = {
          general: /^\[warn\]: @.* tag has duplicate/,
          message: /\[warn\]: (@.*)/,
          location: /in file `(.*)'/,
          line: /line (\d*)/
        }.freeze
      end
    end
  end
end
