# frozen_string_literal: true

RSpec.describe Yard::Lint::Validators::Tags::ExampleSyntax::Parser do
  let(:parser) { described_class.new }

  describe '#initialize' do
    it 'inherits from parser base class' do
      expect(parser).to be_a(Yard::Lint::Parsers::Base)
    end
  end

  describe '#call' do
    it 'parses input and returns array' do
      result = parser.call('')
      expect(result).to be_an(Array)
    end

    it 'handles empty input' do
      result = parser.call('')
      expect(result).to eq([])
    end

    it 'parses syntax error output correctly' do
      output = <<~OUTPUT
        lib/example.rb:10: Example#method
        syntax_error
        Basic usage
        syntax error, unexpected end-of-input
      OUTPUT

      result = parser.call(output)
      expect(result).to eq(
        [
          {
            name: 'ExampleSyntax',
            object_name: 'Example#method',
            example_name: 'Basic usage',
            error_message: 'syntax error, unexpected end-of-input',
            location: 'lib/example.rb',
            line: 10
          }
        ]
      )
    end

    it 'parses multi-line syntax error output correctly' do
      output = <<~OUTPUT
        lib/example.rb:10: Example#method
        syntax_error
        Basic usage
        <compiled>:1: syntax errors found
        > 1 | result = broken
            |                ^ unexpected end-of-input
      OUTPUT

      result = parser.call(output)
      expect(result).to eq(
        [
          {
            name: 'ExampleSyntax',
            object_name: 'Example#method',
            example_name: 'Basic usage',
            error_message: "<compiled>:1: syntax errors found\n> 1 | result = broken\n    " \
                           '|                ^ unexpected end-of-input',
            location: 'lib/example.rb',
            line: 10
          }
        ]
      )
    end

    it 'parses multiple errors correctly' do
      output = <<~OUTPUT
        lib/example.rb:10: Example#method1
        syntax_error
        First example
        error line 1
        error line 2
        lib/example.rb:20: Example#method2
        syntax_error
        Second example
        another error
      OUTPUT

      result = parser.call(output)
      expect(result.length).to eq(2)
      expect(result[0][:error_message]).to eq("error line 1\nerror line 2")
      expect(result[1][:error_message]).to eq('another error')
    end

    it 'handles nil input' do
      result = parser.call(nil)
      expect(result).to eq([])
    end

    it 'ignores lines that do not match location pattern' do
      output = <<~OUTPUT
        random text
        more random text
        lib/example.rb:10: Example#method
        syntax_error
        Basic usage
        error message
      OUTPUT

      result = parser.call(output)
      expect(result.length).to eq(1)
      expect(result[0][:object_name]).to eq('Example#method')
    end

    it 'skips errors without syntax_error status' do
      output = <<~OUTPUT
        lib/example.rb:10: Example#method
        other_error
        Basic usage
        error message
      OUTPUT

      result = parser.call(output)
      expect(result).to eq([])
    end

    it 'handles file paths starting with dot' do
      output = <<~OUTPUT
        ./lib/example.rb:10: Example#method
        syntax_error
        Basic usage
        error message
      OUTPUT

      result = parser.call(output)
      expect(result.length).to eq(1)
      expect(result[0][:location]).to eq('./lib/example.rb')
    end

    it 'handles file paths starting with slash' do
      output = <<~OUTPUT
        /home/user/lib/example.rb:10: Example#method
        syntax_error
        Basic usage
        error message
      OUTPUT

      result = parser.call(output)
      expect(result.length).to eq(1)
      expect(result[0][:location]).to eq('/home/user/lib/example.rb')
    end

    it 'does not match <compiled> as file path' do
      output = <<~OUTPUT
        lib/example.rb:10: Example#method
        syntax_error
        Basic usage
        <compiled>:1: syntax error
        more error details
      OUTPUT

      result = parser.call(output)
      expect(result.length).to eq(1)
      expect(result[0][:error_message]).to include('<compiled>:1: syntax error')
    end
  end
end
