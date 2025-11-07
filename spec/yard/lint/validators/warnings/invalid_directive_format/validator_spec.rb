# frozen_string_literal: true

RSpec.describe Yard::Lint::Validators::Warnings::InvalidDirectiveFormat::Validator do
  let(:config) { Yard::Lint::Config.new }
  let(:selection) { ['lib/example.rb'] }
  let(:validator) { described_class.new(config, selection) }

  describe '#initialize' do
    it 'inherits from Base validator' do
      expect(validator).to be_a(Yard::Lint::Validators::Base)
    end
  end

  describe '#call' do
    it 'returns a hash with stdout, stderr, exit_code keys' do
      allow(validator).to receive(:shell).and_return({ stdout: '', stderr: '', exit_code: 0 })
      
      result = validator.call
      
      expect(result).to be_a(Hash)
      expect(result).to have_key(:stdout)
      expect(result).to have_key(:stderr)
      expect(result).to have_key(:exit_code)
    end
  end
end
