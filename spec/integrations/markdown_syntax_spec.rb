# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'MarkdownSyntax validator' do
  let(:config) { Yard::Lint::Config.new }
  let(:validator) do
    Yard::Lint::Validators::Documentation::MarkdownSyntax::Validator.new(config, [])
  end

  context 'when documentation has unclosed backtick' do
    it 'detects the error' do
      file_content = <<~RUBY
        # Process data with `unclosed backtick
        def process(data)
          # implementation
        end
      RUBY

      with_test_file(file_content) do |path|
        result = validator.call(
          `#{Yard::Lint::YardRunner.build_command(validator, [path])}`
        )

        expect(result.offenses).not_to be_empty
        expect(result.offenses.first[:errors]).to include('unclosed_backtick')
      end
    end
  end

  context 'when documentation has unclosed bold' do
    it 'detects the error' do
      file_content = <<~RUBY
        # Process data with **bold text that is not closed
        def process(data)
          # implementation
        end
      RUBY

      with_test_file(file_content) do |path|
        result = validator.call(
          `#{Yard::Lint::YardRunner.build_command(validator, [path])}`
        )

        expect(result.offenses).not_to be_empty
        expect(result.offenses.first[:errors]).to include('unclosed_bold')
      end
    end
  end

  context 'when documentation has invalid list marker' do
    it 'detects the error' do
      file_content = <<~RUBY
        # Process data
        # • Invalid bullet point
        def process(data)
          # implementation
        end
      RUBY

      with_test_file(file_content) do |path|
        result = validator.call(
          `#{Yard::Lint::YardRunner.build_command(validator, [path])}`
        )

        expect(result.offenses).not_to be_empty
        invalid_marker = result.offenses.first[:errors].find do |e|
          e.start_with?('invalid_list_marker:')
        end
        expect(invalid_marker).not_to be_nil
      end
    end
  end

  context 'when documentation has valid markdown' do
    it 'does not flag the method' do
      file_content = <<~RUBY
        # Process data with `proper code` and **bold** text
        # - Valid list item
        # * Another valid item
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

  context 'when documentation has multiple errors' do
    it 'detects all errors' do
      file_content = <<~RUBY
        # Process data with `unclosed backtick and **unclosed bold
        def process(data)
          # implementation
        end
      RUBY

      with_test_file(file_content) do |path|
        result = validator.call(
          `#{Yard::Lint::YardRunner.build_command(validator, [path])}`
        )

        expect(result.offenses).not_to be_empty
        errors = result.offenses.first[:errors]
        expect(errors).to include('unclosed_backtick')
        expect(errors).to include('unclosed_bold')
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
