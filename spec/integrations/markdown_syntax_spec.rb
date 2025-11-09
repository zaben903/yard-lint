# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'MarkdownSyntax validator' do
  let(:config) do
    Yard::Lint::Config.new do |c|
      c.send(:set_validator_config, 'Documentation/MarkdownSyntax', 'Enabled', true)
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

  context 'when documentation has unclosed backtick' do
    it 'detects the error' do
      file = create_test_file('unclosed_backtick.rb', <<~RUBY)
        # Process data with `unclosed backtick
        def process(data)
          # implementation
        end
      RUBY

      result = Yard::Lint.run(path: file, config: config)
      markdown_errors = result.offenses.select { |o| o[:name].to_s == 'MarkdownSyntax' }

      expect(markdown_errors).not_to be_empty
      expect(markdown_errors.first[:message]).to include('Unclosed backtick')
    end
  end

  context 'when documentation has unclosed bold' do
    it 'detects the error' do
      file = create_test_file('unclosed_bold.rb', <<~RUBY)
        # Process data with **bold text that is not closed
        def process(data)
          # implementation
        end
      RUBY

      result = Yard::Lint.run(path: file, config: config)
      markdown_errors = result.offenses.select { |o| o[:name].to_s == 'MarkdownSyntax' }

      expect(markdown_errors).not_to be_empty
      expect(markdown_errors.first[:message]).to include('Unclosed bold formatting')
    end
  end

  context 'when documentation has invalid list marker' do
    it 'detects the error' do
      file = create_test_file('invalid_list.rb', <<~RUBY)
        # Process data
        # • Invalid bullet point
        def process(data)
          # implementation
        end
      RUBY

      result = Yard::Lint.run(path: file, config: config)
      markdown_errors = result.offenses.select { |o| o[:name].to_s == 'MarkdownSyntax' }

      expect(markdown_errors).not_to be_empty
      expect(markdown_errors.first[:message]).to include('Invalid list marker')
    end
  end

  context 'when documentation has valid markdown' do
    it 'does not flag the method' do
      file = create_test_file('valid_markdown.rb', <<~RUBY)
        # Process data with `proper code` and **bold** text
        # - Valid list item
        # * Another valid item
        def process(data)
          # implementation
        end
      RUBY

      result = Yard::Lint.run(path: file, config: config)
      markdown_errors = result.offenses.select { |o| o[:name].to_s == 'MarkdownSyntax' }

      expect(markdown_errors).to be_empty
    end
  end

  context 'when documentation has multiple errors' do
    it 'detects all errors' do
      file = create_test_file('multiple_errors.rb', <<~RUBY)
        # Process data with `unclosed backtick and **unclosed bold
        def process(data)
          # implementation
        end
      RUBY

      result = Yard::Lint.run(path: file, config: config)
      markdown_errors = result.offenses.select { |o| o[:name].to_s == 'MarkdownSyntax' }

      expect(markdown_errors).not_to be_empty
      message = markdown_errors.first[:message]
      expect(message).to include('Unclosed backtick')
      expect(message).to include('Unclosed bold formatting')
    end
  end
end
