# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Yard::Lint::Validators::Documentation::MarkdownSyntax::Parser do
  describe '.parse' do
    context 'with valid violations' do
      it 'parses single error' do
        output = <<~OUTPUT
          lib/example.rb:10: MyClass#process
          unclosed_backtick
        OUTPUT

        result = described_class.parse(output)

        expect(result).to eq([
          {
            location: 'lib/example.rb',
            line: 10,
            object_name: 'MyClass#process',
            errors: ['unclosed_backtick']
          }
        ])
      end

      it 'parses multiple errors for same object' do
        output = <<~OUTPUT
          lib/example.rb:10: MyClass#process
          unclosed_backtick|unclosed_bold
        OUTPUT

        result = described_class.parse(output)

        expect(result).to eq([
          {
            location: 'lib/example.rb',
            line: 10,
            object_name: 'MyClass#process',
            errors: ['unclosed_backtick', 'unclosed_bold']
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

        result = described_class.parse(output)

        expect(result).to eq([
          {
            location: 'lib/example.rb',
            line: 10,
            object_name: 'MyClass#process',
            errors: ['unclosed_backtick']
          },
          {
            location: 'lib/example.rb',
            line: 20,
            object_name: 'MyClass#execute',
            errors: ['unclosed_bold']
          }
        ])
      end

      it 'parses invalid list marker with line number' do
        output = <<~OUTPUT
          lib/example.rb:15: MyClass#configure
          invalid_list_marker:3
        OUTPUT

        result = described_class.parse(output)

        expect(result).to eq([
          {
            location: 'lib/example.rb',
            line: 15,
            object_name: 'MyClass#configure',
            errors: ['invalid_list_marker:3']
          }
        ])
      end
    end

    context 'with empty output' do
      it 'returns empty array' do
        result = described_class.parse('')
        expect(result).to eq([])
      end
    end
  end
end
