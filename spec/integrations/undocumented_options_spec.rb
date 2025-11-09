# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'UndocumentedOptions validator' do
  let(:config) { Yard::Lint::Config.new }
  let(:validator) do
    Yard::Lint::Validators::Documentation::UndocumentedOptions::Validator.new(config, [])
  end

  context 'when method has options parameter without @option tags' do
    it 'detects options = {}' do
      file_content = <<~RUBY
        # Process data
        def process(data, options = {})
          # implementation
        end
      RUBY

      with_test_file(file_content) do |path|
        result = validator.call(
          `#{Yard::Lint::YardRunner.build_command(validator, [path])}`
        )

        expect(result.offenses).not_to be_empty
        expect(result.offenses.first[:object_name]).to include('#process')
        expect(result.offenses.first[:params]).to include('options')
      end
    end

    it 'detects opts = {}' do
      file_content = <<~RUBY
        # Execute task
        def execute(data, opts = {})
          # implementation
        end
      RUBY

      with_test_file(file_content) do |path|
        result = validator.call(
          `#{Yard::Lint::YardRunner.build_command(validator, [path])}`
        )

        expect(result.offenses).not_to be_empty
        expect(result.offenses.first[:params]).to include('opts')
      end
    end

    it 'detects **kwargs' do
      file_content = <<~RUBY
        # Configure settings
        def configure(**options)
          # implementation
        end
      RUBY

      with_test_file(file_content) do |path|
        result = validator.call(
          `#{Yard::Lint::YardRunner.build_command(validator, [path])}`
        )

        expect(result.offenses).not_to be_empty
        expect(result.offenses.first[:params]).to include('**options')
      end
    end
  end

  context 'when method has options parameter with @option tags' do
    it 'does not flag the method' do
      file_content = <<~RUBY
        # Process data
        # @param data [Hash] the data
        # @param options [Hash] processing options
        # @option options [String] :format output format
        def process(data, options = {})
          # implementation
        end
      RUBY

      with_test_file(file_content) do |path|
        result = validator.call(
          `#{Yard::Lint::YardRunner.build_command(validator, [path])}`
        )

        expect(result.offenses).to be_empty
      end
    end
  end

  context 'when method has no options parameter' do
    it 'does not flag the method' do
      file_content = <<~RUBY
        # Process data
        # @param data [Hash] the data
        def process(data)
          # implementation
        end
      RUBY

      with_test_file(file_content) do |path|
        result = validator.call(
          `#{Yard::Lint::YardRunner.build_command(validator, [path])}`
        )

        expect(result.offenses).to be_empty
      end
    end
  end

  def with_test_file(content)
    file = Tempfile.new(['test', '.rb'])
    file.write(content)
    file.close

    yield file.path
  ensure
    file.unlink if file
  end
end
