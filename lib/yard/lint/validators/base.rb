# frozen_string_literal: true

require 'shellwords'
require 'open3'
require 'tmpdir'

module Yard
  module Lint
    module Validators
      # Base YARD validator class
      class Base
        # Default yard stats options that we need to use
        DEFAULT_OPTIONS = [
          '--charset utf-8',
          '--markup markdown',
          '--no-progress'
        ].freeze

        # String with a temp dir to store the yard stats database
        # @note We run yard multiple times and in order not to rebuild db over and over
        #   again but reuse the same one, we have a single tmp dir for it
        YARDOC_TEMP_DIR = Dir.mktmpdir.freeze

        private_constant :YARDOC_TEMP_DIR

        attr_reader :config, :selection

        # @param config [Yard::Lint::Config] configuration object
        # @param selection [Array<String>] array with ruby files we want to check
        def initialize(config, selection)
          @config = config
          @selection = selection
        end

        # Performs the validation and returns raw results
        # @return [Hash] hash with stdout, stderr and exit_code keys
        def call
          # There might be a case when there were no files because someone ignored all
          # then we need to return empty result
          return raw if selection.nil? || selection.empty?

          # Anything that goes to shell needs to be escaped
          escaped_file_names = escape(selection).join(' ')

          yard_cmd(YARDOC_TEMP_DIR, escaped_file_names)
        end

        private

        # @return [String] all arguments with which yard stats should be executed
        def shell_arguments
          args = escape(config.options).join(' ')
          "#{args} #{DEFAULT_OPTIONS.join(' ')}"
        end

        # @param array [Array] escape all elements in an array
        # @return [Array] array with escaped elements
        def escape(array)
          array.map { |cmd| Shellwords.escape(cmd) }
        end

        # Builds a raw hash that can be used for further processing
        # @param stdout [String, Hash, Array] anything that we want to return as stdout
        # @param stderr [String, Hash, Array] any errors that occurred
        # @param exit_code [Integer, false] result exit code or false if we want to decide it based
        #   on the stderr content
        # @return [Hash] hash with stdout, stderr and exit_code keys
        def raw(stdout = '', stderr = '', exit_code = false)
          {
            stdout: stdout,
            stderr: stderr,
            exit_code: exit_code || (stderr.empty? ? 0 : 1)
          }
        end

        # Executes a shell command and returns the result
        # @param cmd [String] shell command to execute
        # @return [Hash] hash with stdout, stderr and exit_code keys
        def shell(cmd)
          stdout, stderr, status = Open3.capture3(cmd)
          {
            stdout: stdout,
            stderr: stderr,
            exit_code: status.exitstatus
          }
        end
      end
    end
  end
end
