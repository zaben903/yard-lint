# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Yard::Lint::Validators::Documentation::UndocumentedOptions::Parser do
  let(:parser) { described_class.new }

  describe '#call' do
    context 'with valid violations' do
      it 'parses single violation' do
        output = <<~OUTPUT
          lib/example.rb:10: MyClass#process
          data, options = {}
        OUTPUT

        result = parser.call(output)

        expect(result).to eq([
          {
            location: 'lib/example.rb',
            line: 10,
            object_name: 'MyClass#process',
            params: 'data, options = {}'
          }
        ])
      end

      it 'parses multiple violations' do
        output = <<~OUTPUT
          lib/example.rb:10: MyClass#process
          data, options = {}
          lib/example.rb:20: MyClass#execute
          data, opts = {}
        OUTPUT

        result = parser.call(output)

        expect(result).to eq([
          {
            location: 'lib/example.rb',
            line: 10,
            object_name: 'MyClass#process',
            params: 'data, options = {}'
          },
          {
            location: 'lib/example.rb',
            line: 20,
            object_name: 'MyClass#execute',
            params: 'data, opts = {}'
          }
        ])
      end

      it 'parses violation with kwargs' do
        output = <<~OUTPUT
          lib/example.rb:15: MyClass#configure
          **options
        OUTPUT

        result = parser.call(output)

        expect(result).to eq([
          {
            location: 'lib/example.rb',
            line: 15,
            object_name: 'MyClass#configure',
            params: '**options'
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
