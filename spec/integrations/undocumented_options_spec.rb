# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'UndocumentedOptions validator' do
  let(:config) do
    Yard::Lint::Config.new do |c|
      c.send(:set_validator_config, 'Documentation/UndocumentedOptions', 'Enabled', true)
    end
  end

  let(:test_dir) { Dir.mktmpdir }

  after { FileUtils.rm_rf(test_dir) if test_dir && File.exist?(test_dir) }

  def create_test_file(filename, content)
    path = File.join(test_dir, filename)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
    path
  end

  context 'when method has options parameter without @option tags' do
    it 'detects options = {}' do
      file = create_test_file('process.rb', <<~RUBY)
        # Process data
        def process(data, options = {})
          # implementation
        end
      RUBY

      result = Yard::Lint.run(path: file, config: config)
      undocumented_options = result.offenses.select { |o| o[:name].to_s == 'UndocumentedOptions' }

      expect(undocumented_options).not_to be_empty
      expect(undocumented_options.first[:message]).to include('process')
      expect(undocumented_options.first[:message]).to include('options')
    end

    it 'detects opts = {}' do
      file = create_test_file('execute.rb', <<~RUBY)
        # Execute task
        def execute(data, opts = {})
          # implementation
        end
      RUBY

      result = Yard::Lint.run(path: file, config: config)
      undocumented_options = result.offenses.select { |o| o[:name].to_s == 'UndocumentedOptions' }

      expect(undocumented_options).not_to be_empty
      expect(undocumented_options.first[:message]).to include('opts')
    end

    it 'detects **kwargs' do
      file = create_test_file('configure.rb', <<~RUBY)
        # Configure settings
        def configure(**options)
          # implementation
        end
      RUBY

      result = Yard::Lint.run(path: file, config: config)
      undocumented_options = result.offenses.select { |o| o[:name].to_s == 'UndocumentedOptions' }

      expect(undocumented_options).not_to be_empty
      expect(undocumented_options.first[:message]).to include('**options')
    end
  end

  context 'when method has options parameter with @option tags' do
    it 'does not flag the method' do
      file = create_test_file('process_with_options.rb', <<~RUBY)
        # Process data
        # @param data [Hash] the data
        # @param options [Hash] processing options
        # @option options [String] :format output format
        def process(data, options = {})
          # implementation
        end
      RUBY

      result = Yard::Lint.run(path: file, config: config)
      undocumented_options = result.offenses.select { |o| o[:name].to_s == 'UndocumentedOptions' }

      expect(undocumented_options).to be_empty
    end
  end

  context 'when method has no options parameter' do
    it 'does not flag the method' do
      file = create_test_file('process_simple.rb', <<~RUBY)
        # Process data
        # @param data [Hash] the data
        def process(data)
          # implementation
        end
      RUBY

      result = Yard::Lint.run(path: file, config: config)
      undocumented_options = result.offenses.select { |o| o[:name].to_s == 'UndocumentedOptions' }

      expect(undocumented_options).to be_empty
    end
  end
end
