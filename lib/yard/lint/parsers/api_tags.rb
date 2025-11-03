# frozen_string_literal: true

module Yard
  module Lint
    module Parsers
      # Parser for @api tag validation results
      class ApiTags < Base
        # @param yard_output [String] raw yard output with API tag issues
        # @return [Array<Hash>] array with API tag violation details
        def call(yard_output)
          return [] if yard_output.nil? || yard_output.empty?

          lines = yard_output.split("\n").reject(&:empty?)
          results = []

          lines.each_slice(2) do |location_line, status_line|
            next unless location_line && status_line

            # Parse location line: "file.rb:10: ClassName#method_name"
            match = location_line.match(/^(.+):(\d+): (.+)$/)
            next unless match

            file = match[1]
            line = match[2].to_i
            object_name = match[3]

            # Determine message based on status
            message = if status_line == 'missing'
                        "Public object `#{object_name}` is missing @api tag"
                      else
                        api_value = status_line.sub('invalid:', '')
                        "Object `#{object_name}` has invalid @api tag value: '#{api_value}'"
                      end

            results << {
              name: 'ApiTag',
              message: message,
              location: file,
              line: line
            }
          end

          results
        end
      end
    end
  end
end
