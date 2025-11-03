# frozen_string_literal: true

module Yard
  module Lint
    module Parsers
      # Class used to extract warnings details that are related to yard invalid tag formats
      # @example
      #   [warn]: Invalid tag format for @example in file `app/models/offense.rb` near line 28
      class InvalidTagFormat < OneLineBase
        # Set of regexps for detecting warnings reported by yard stats
        self.regexps = {
          general: /^\[warn\]: Invalid tag format for .*@.*near line/,
          message: /\[warn\]: (.*) in file/,
          location: /in file `(.*)`/,
          line: /line (\d*)/
        }.freeze
      end
    end
  end
end
