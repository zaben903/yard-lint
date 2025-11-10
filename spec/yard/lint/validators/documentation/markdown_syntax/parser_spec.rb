# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Yard::Lint::Validators::Documentation::MarkdownSyntax::Parser do
  let(:parser) { described_class.new }

  describe '#call' do
    context 'with valid violations' do
      it 'parses single error' do
        output = <<~OUTPUT
          lib/example.rb:10: MyClass#process
          unclosed_backtick
        OUTPUT

        result = parser.call(output)

        expect(result).to eq([
          {
            location: 'lib/example.rb',
            line: 10,
            object_name: 'MyClass#process',
            errors: %w[unclosed_backtick]
          }
        ])
      end

      it 'parses multiple errors for same object' do
        output = <<~OUTPUT
          lib/example.rb:10: MyClass#process
          unclosed_backtick|unclosed_bold
        OUTPUT

        result = parser.call(output)

        expect(result).to eq([
          {
            location: 'lib/example.rb',
            line: 10,
            object_name: 'MyClass#process',
            errors: %w[unclosed_backtick unclosed_bold]
          }
        ])
      end

      it 'parses multiple violations' do
        output = <<~OUTPUT
          lib/example.rb:10: MyClass#process
          unclosed_backtick
          lib/example.rb:20: MyClass#execute
          unclosed_bold
        OUTPUT

        result = parser.call(output)

        expect(result).to eq([
          {
            location: 'lib/example.rb',
            line: 10,
            object_name: 'MyClass#process',
            errors: %w[unclosed_backtick]
          },
          {
            location: 'lib/example.rb',
            line: 20,
            object_name: 'MyClass#execute',
            errors: %w[unclosed_bold]
          }
        ])
      end

      it 'parses invalid list marker with line number' do
        output = <<~OUTPUT
          lib/example.rb:15: MyClass#configure
          invalid_list_marker:3
        OUTPUT

        result = parser.call(output)

        expect(result).to eq([
          {
            location: 'lib/example.rb',
            line: 15,
            object_name: 'MyClass#configure',
            errors: %w[invalid_list_marker:3]
          }
        ])
      end
    end

    context 'with empty output' do
      it 'returns empty array' do
        result = parser.call('')
        expect(result).to eq([])
      end
    end
  end
end
