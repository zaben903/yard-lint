# frozen_string_literal: true

RSpec.describe Yard::Lint::Validators::Documentation::UndocumentedOptions::Result do
  let(:config) { Yard::Lint::Config.new }
  let(:parsed_data) { [] }
  let(:result) { described_class.new(parsed_data, config) }

  describe '#initialize' do
    it 'inherits from Results::Base' do
      expect(result).to be_a(Yard::Lint::Results::Base)
    end

    it 'stores config' do
      expect(result.instance_variable_get(:@config)).to eq(config)
    end
  end

  describe '#offenses' do
    it 'returns an array' do
      expect(result.offenses).to be_an(Array)
    end

    it 'handles empty parsed data' do
      expect(result.offenses).to eq([])
    end

    it 'formats message for offense with options parameter' do
      parsed_offense = {
        location: 'lib/example.rb',
        line: 10,
        object_name: 'MyClass#process',
        params: 'data, options = {}'
      }
      result_with_offense = described_class.new([parsed_offense], config)
      built_offense = result_with_offense.offenses.first

      expect(built_offense[:message]).to eq(
        "Method 'MyClass#process' has options parameter (data, options = {}) " \
        'but no @option tags in documentation.'
      )
    end

    it 'formats message for offense with kwargs' do
      parsed_offense = {
        location: 'lib/example.rb',
        line: 15,
        object_name: 'MyClass#configure',
        params: '**options'
      }
      result_with_offense = described_class.new([parsed_offense], config)
      built_offense = result_with_offense.offenses.first

      expect(built_offense[:message]).to eq(
        "Method 'MyClass#configure' has options parameter (**options) " \
        'but no @option tags in documentation.'
      )
    end
  end

  describe 'class methods' do
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
