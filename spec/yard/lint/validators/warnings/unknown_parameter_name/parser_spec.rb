# frozen_string_literal: true

RSpec.describe Yard::Lint::Validators::Warnings::UnknownParameterName::Parser do
  let(:parser) { described_class.new }

  describe '#initialize' do
    it 'inherits from TwoLineBase parser' do
      expect(parser).to be_a(Yard::Lint::Parsers::TwoLineBase)
    end
  end

  describe '.regexps' do
    it 'defines required regexps' do
      expect(described_class.regexps).to be_a(Hash)
      expect(described_class.regexps).to have_key(:general)
      expect(described_class.regexps).to have_key(:message)
      expect(described_class.regexps).to have_key(:location)
      expect(described_class.regexps).to have_key(:line)
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
  end
end
