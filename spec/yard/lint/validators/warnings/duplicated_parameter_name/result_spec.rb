# frozen_string_literal: true

RSpec.describe Yard::Lint::Validators::Warnings::DuplicatedParameterName::Result do
  let(:config) { Yard::Lint::Config.new }
  let(:parsed_data) { [] }
  let(:result) { described_class.new(parsed_data, config) }

  describe '#initialize' do
    it 'inherits from Base result' do
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

    it 'returns empty array for empty parsed data' do
      expect(result.offenses).to eq([])
    end
  end
end
