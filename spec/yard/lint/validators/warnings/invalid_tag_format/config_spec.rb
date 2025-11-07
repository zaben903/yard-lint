# frozen_string_literal: true

RSpec.describe Yard::Lint::Validators::Warnings::InvalidTagFormat::Config do
  describe '.id' do
    it 'returns the validator identifier' do
      expect(described_class.id).to eq(:invalid_tag_format)
    end
  end

  describe '.defaults' do
    it 'returns default configuration' do
      expect(described_class.defaults).to eq(
        'Enabled' => true,
        'Severity' => 'error'
      )
    end

    it 'returns frozen hash' do
      expect(described_class.defaults).to be_frozen
    end
  end

  describe '.combines_with' do
    it 'returns empty array for standalone validator' do
      expect(described_class.combines_with).to eq([])
    end
  end

  describe 'inheritance' do
    it 'inherits from base Config class' do
      expect(described_class.superclass).to eq(Yard::Lint::Validators::Config)
    end
  end
end
