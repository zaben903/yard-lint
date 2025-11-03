# frozen_string_literal: true

module Yard
  module Lint
    module Parsers
      # Class used to extract warnings details that are related to yard unknown directives
      # @example
      #   [warn]: Unknown directive @!param1 in file `app/models/offense.rb` near line 28
      class UnknownDirective < OneLineBase
        # Set of regexps for detecting warnings reported by yard stats
        self.regexps = {
          general: /^\[warn\]: Unknown directive.*@.*near line/,
          message: /\[warn\]: (.*) in file/,
          location: /in file `(.*)`/,
          line: /line (\d*)/
        }.freeze
      end
    end
  end
end
