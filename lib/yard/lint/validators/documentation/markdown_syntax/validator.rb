# frozen_string_literal: true

module Yard
  module Lint
    module Validators
      module Documentation
        module MarkdownSyntax
          # Validates markdown syntax in documentation
          class Validator < Validators::Base
            # YARD query to extract docstrings and check for markdown errors
            # @return [String] YARD Ruby query code
            def query
              <<~QUERY.strip
                '
                docstring_text = object.docstring.to_s
                unless docstring_text.empty?
                  errors = []

                  # Check for unclosed backticks
                  backtick_count = docstring_text.scan(/`/).count
                  if backtick_count.odd?
                    errors << "unclosed_backtick"
                  end

                  # Check for unclosed code blocks
                  code_block_starts = docstring_text.scan(/^```/).count
                  code_block_ends = docstring_text.scan(/^```/).count
                  if code_block_starts != code_block_ends
                    errors << "unclosed_code_block"
                  end

                  # Check for broken bold/italic formatting
                  # ** without matching pair (not inside code)
                  non_code_text = docstring_text.gsub(/`[^`]*`/, "")
                  bold_count = non_code_text.scan(/\*\*/).count
                  if bold_count.odd?
                    errors << "unclosed_bold"
                  end

                  # Check for malformed lists (list items not starting with - or *)
                  lines = docstring_text.lines
                  lines.each_with_index do |line, line_idx|
                    # Detect lines that look like list items but have wrong syntax
                    # e.g., "•" or numbers without proper format
                    stripped = line.strip
                    # Check for bullet-like characters that are not markdown
                    if stripped =~ /^[•·]/
                      errors << "invalid_list_marker:" + (line_idx + 1).to_s
                    end
                  end

                  unless errors.empty?
                    puts object.file + ":" + object.line.to_s + ": " + object.title
                    puts errors.join("|")
                  end
                end
                false
                '
              QUERY
            end

            # Builds and executes the YARD command to detect markdown syntax errors
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
