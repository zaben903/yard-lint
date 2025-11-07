# frozen_string_literal: true

module Yard
  module Lint
    # Result objects for validators
    module Results
      # Aggregates multiple validator results into a single result object
      class Aggregate
        # Error severity level constant
        SEVERITY_ERROR = 'error'
        # Warning severity level constant
        SEVERITY_WARNING = 'warning'
        # Convention severity level constant
        SEVERITY_CONVENTION = 'convention'

        attr_reader :config

        # Initialize aggregate result with array of validator results
        # @param results [Array<Results::Base>] array of validator result objects
        # @param config [Config, nil] configuration object
        def initialize(results, config = nil)
          @results = Array(results)
          @config = config
        end

        # Get all offenses from all validators
        # @return [Array<Hash>] flattened array of all offenses
        def offenses
          @results.flat_map(&:offenses)
        end

        # Total number of offenses
        # @return [Integer] offense count
        def count
          offenses.count
        end

        # Check if there are no offenses
        # @return [Boolean] true if no offenses found
        def clean?
          offenses.empty?
        end

        # Get offense statistics by severity
        # @return [Hash] hash with severity counts (using symbol keys)
        def statistics
          stats = {
            error: 0,
            warning: 0,
            convention: 0,
            total: 0
          }

          offenses.each do |offense|
            severity = offense[:severity].to_sym
            stats[severity] += 1 if stats.key?(severity)
            stats[:total] += 1
          end

          stats
        end

        # Determine exit code based on configured fail_on_severity
        # Uses the config object stored during initialization
        # @return [Integer] 0 for success, 1 for failure
        def exit_code
          return 0 if offenses.empty?
          return 0 unless @config # No config means don't fail

          fail_on = @config.fail_on_severity

          case fail_on
          when SEVERITY_ERROR
            statistics[:error].positive? ? 1 : 0
          when SEVERITY_WARNING
            (statistics[:error] + statistics[:warning]).positive? ? 1 : 0
          when SEVERITY_CONVENTION
            offenses.any? ? 1 : 0
          else
            0
          end
        end
      end
    end
  end
end
