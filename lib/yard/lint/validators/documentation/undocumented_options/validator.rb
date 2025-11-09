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

            # Builds and executes the YARD command to detect undocumented options
            # @param dir [String] the directory containing the .yardoc database
            # @param file_list_path [String] path to file containing list of files to analyze
            # @return [String] command output
            def yard_cmd(dir, file_list_path)
              cmd = <<~CMD
                cat #{Shellwords.escape(file_list_path)} | xargs yard list \
                  #{shell_arguments} \
                --query #{query} \
                -q \
                -b #{Shellwords.escape(dir)}
              CMD
              cmd = cmd.tr("\n", ' ')
              shell(cmd)
            end
          end
        end
      end
    end
  end
end
