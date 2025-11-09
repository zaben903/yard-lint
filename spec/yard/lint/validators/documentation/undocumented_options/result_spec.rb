# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Yard::Lint::Validators::Documentation::UndocumentedOptions::Result do
  describe '#build_message' do
    it 'formats message with object name and params' do
      offense = {
        location: 'lib/example.rb',
        line: 10,
        object_name: 'MyClass#process',
        params: 'data, options = {}'
      }

      result = described_class.new(
        severity: 'warning',
        offenses: [offense]
      )

      # Get the built offense from the result
      built_offense = result.offenses.first

      expect(built_offense[:message]).to eq(
        "Method 'MyClass#process' has options parameter (data, options = {}) " \
        'but no @option tags in documentation.'
      )
    end

    it 'formats message with kwargs' do
      offense = {
        location: 'lib/example.rb',
        line: 15,
        object_name: 'MyClass#configure',
        params: '**options'
      }

      result = described_class.new(
        severity: 'warning',
        offenses: [offense]
      )

      # Get the built offense from the result
      built_offense = result.offenses.first

      expect(built_offense[:message]).to eq(
        "Method 'MyClass#configure' has options parameter (**options) " \
        'but no @option tags in documentation.'
      )
    end
  end

  describe 'class configuration' do
    it 'has correct default severity' do
      expect(described_class.default_severity).to eq('warning')
    end

    it 'has correct offense type' do
      expect(described_class.offense_type).to eq('line')
    end

    it 'has correct offense name' do
      expect(described_class.offense_name).to eq('UndocumentedOptions')
    end
  end
end
