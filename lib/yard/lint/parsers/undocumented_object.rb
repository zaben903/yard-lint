# frozen_string_literal: true

module Yard
  module Lint
    module Parsers
      # Class used to extract details about undocumented objects from raw yard stats string
      # @example
      #   (in file: app/concepts/platform/analysis/authors/contracts.rb)
      #   Platform::Analysis::Authors                (app/concepts/diff_gem.rb:3)
      #   Platform::Analysis::Authors::Contracts     (app/concepts/diff_gem.rb:6)
      class UndocumentedObject < Base
        # String with which the undocumented section starts
        UNDOCUMENTED_START = 'Undocumented Objects:'

        # Regex used to extract file location from the report line
        LOCATION_REGEX = /\((.*):\d+\)/

        private_constant :UNDOCUMENTED_START, :LOCATION_REGEX

        # @param yard_stats [String] raw yard stats results string
        # @return [Array<Hash>] Array with undocumented objects details
        def call(yard_stats)
          # Not all the lines from the yard_stats output are valuable, that's why we filter
          # them out, preprocess and leave only those against which we should match
          yard_stats
            .split("\n")
            .then { |rows| classify(rows) }
            .map do |undocumented_details|
              {
                location: undocumented_details.match(LOCATION_REGEX)[1],
                line: undocumented_details.split(':').last.to_i,
                element: undocumented_details.split[0]
              }
            end
        end

        private

        # @param rows [Array<String>] array with lines of output from yard stats
        # @return [Array<String>] Array with undocumented objects
        def classify(rows)
          buffor = []
          started = false

          rows.each do |row|
            started = false if row.empty?

            if row.include?(UNDOCUMENTED_START)
              started = true
            else
              next unless started
              next unless row.match?(LOCATION_REGEX)

              buffor << row
            end
          end

          buffor
        end
      end
    end
  end
end
