# frozen_string_literal: true

module Yard
  module Lint
    module Validators
      # Runs a query that will pick all the objects that have invalid type definitions
      # By invalid we mean, that they are not classes nor any of the allowed defaults or
      # exclusions.
      class InvalidTagsTypes < Base
        # All non-class yard types that are considered valid
        ALLOWED_DEFAULTS = %w[
          false
          true
          nil
          self
          vold
        ].freeze

        private_constant :ALLOWED_DEFAULTS

        private

        # Runs yard list query with proper settings on a given dir and files
        # @param dir [String] dir where the yard db is (or where it should be generated)
        # @param escaped_file_names [String] files for which we want to get the stats
        # @return [Hash] shell command execution hash results
        def yard_cmd(dir, escaped_file_names)
          cmd = <<~CMD
            yard list \
            --private \
            --protected \
            -b #{Shellwords.escape(dir)} \
            #{escaped_file_names}
          CMD
          cmd = cmd.tr("\n", ' ')
          cmd = cmd.gsub('yard list', "yard list --query #{query}")

          shell(cmd)
        end

        # @return [String] multiline yard query that we use to find methods with
        #   tags with invalid types definitions
        def query
          <<-QUERY
            '
              sanitize = ->(type) do
                type
                  .tr('=>', '')
                  .tr('<', '')
                  .tr('>', '')
                  .tr(' ', '')
                  .tr(',', '')
                  .tr('{', '')
                  .tr('}', '')
              end

              docstring
                .tags
                .select { |tag| #{checked_tags_names}.include?(tag.tag_name) }
                .map(&:types)
                .flatten
                .uniq
                .compact
                .map(&sanitize)
                .reject { |type| #{allowed_types_code}.include?(type) }
                .reject { |type| !(Kernel.const_defined?(type) rescue nil).nil? }
                .reject { |type| type.include?('#') }
                .then { |types| !types.empty? }
            ' \\
          QUERY
        end

        # @return [String] tags names for which we want to check the invalid tags
        #   types definitions
        def checked_tags_names
          query_array(config.invalid_tags_names)
        end

        # @return [String] extra names that we allow for types definitions in a yard
        #   query acceptable form
        def allowed_types_code
          query_array(ALLOWED_DEFAULTS + config.extra_types)
        end

        # @param elements [Array<String>] array of elements that we want to convert into
        #   a string ruby yard query array form
        # @return [String] array of elements for yard query converted into a string
        def query_array(elements)
          "
            [
              #{elements.map { |type| "\"#{type}\"" }.join(",")}
            ]
          "
        end
      end
    end
  end
end
