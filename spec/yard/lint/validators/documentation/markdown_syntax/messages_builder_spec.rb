# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Yard::Lint::Validators::Documentation::MarkdownSyntax::MessagesBuilder do
  describe '.call' do
    it 'formats unclosed backtick error' do
      offense = {
        object_name: 'MyClass#process',
        errors: ['unclosed_backtick']
      }

      message = described_class.call(offense)

      expect(message).to eq(
        "Markdown syntax errors in 'MyClass#process': " \
        'Unclosed backtick in documentation'
      )
    end

    it 'formats unclosed code block error' do
      offense = {
        object_name: 'MyClass#execute',
        errors: ['unclosed_code_block']
      }

      message = described_class.call(offense)

      expect(message).to eq(
        "Markdown syntax errors in 'MyClass#execute': " \
        'Unclosed code block (```) in documentation'
      )
    end

    it 'formats unclosed bold error' do
      offense = {
        object_name: 'MyClass#configure',
        errors: ['unclosed_bold']
      }

      message = described_class.call(offense)

      expect(message).to eq(
        "Markdown syntax errors in 'MyClass#configure': " \
        'Unclosed bold formatting (**) in documentation'
      )
    end

    it 'formats invalid list marker error with line number' do
      offense = {
        object_name: 'MyClass#setup',
        errors: ['invalid_list_marker:3']
      }

      message = described_class.call(offense)

      expect(message).to eq(
        "Markdown syntax errors in 'MyClass#setup': " \
        'Invalid list marker (use - or * instead) at line 3'
      )
    end

    it 'formats multiple errors' do
      offense = {
        object_name: 'MyClass#process',
        errors: ['unclosed_backtick', 'unclosed_bold']
      }

      message = described_class.call(offense)

      expect(message).to eq(
        "Markdown syntax errors in 'MyClass#process': " \
        'Unclosed backtick in documentation, ' \
        'Unclosed bold formatting (**) in documentation'
      )
    end
  end
end
