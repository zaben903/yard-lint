# frozen_string_literal: true

module Yard
  module Lint
    module Validators
      module Documentation
        module UndocumentedOptions
          # Validates that methods with options hash parameters have @option tags
          class Validator < Validators::Base
            # YARD query to detect methods with options parameters but no @option tags
            # @return [String] YARD Ruby query code
            def query
              <<~QUERY.strip
                '
                if object.is_a?(YARD::CodeObjects::MethodObject)
                  params = object.parameters || []
                  has_options_param = params.any? { |p|
                    # Match options = {}, opts = {}, **kwargs, **options
                    p[0] =~ /^(options?|opts?|kwargs)$/ ||
                    p[0] =~ /^\*\*/ ||
                    (p[0] =~ /^(options?|opts?|kwargs)$/ && p[1] =~ /^\{\}/)
                  }

                  if has_options_param
                    option_tags = object.tags(:option)
                    if option_tags.empty?
                      puts object.file + ":" + object.line.to_s + ": " + object.title
                      puts params.map { |p| p.join(" ") }.join(", ")
                    end
                  end
                end
                false
                '
              QUERY
            end

            # Process YARD output and build result
            # @param output [String] raw YARD command output
            # @return [Result] validation result
            def call(output)
              Result.new(
                severity: severity,
                offenses: Parser.parse(output)
              )
            end
          end
        end
      end
    end
  end
end
