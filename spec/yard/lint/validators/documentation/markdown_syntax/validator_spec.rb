# frozen_string_literal: true

RSpec.describe Yard::Lint::Validators::Documentation::MarkdownSyntax::Validator do
  let(:config) { Yard::Lint::Config.new }
  let(:selection) { ['lib/example.rb'] }
  let(:validator) { described_class.new(config, selection) }

  describe '#initialize' do
    it 'inherits from Base validator' do
      expect(validator).to be_a(Yard::Lint::Validators::Base)
    end

    it 'stores config and selection' do
      expect(validator.config).to eq(config)
      expect(validator.selection).to eq(selection)
    end
  end

  describe '#call' do
    it 'returns hash with stdout, stderr, exit_code' do
      result = validator.call
      expect(result).to have_key(:stdout)
      expect(result).to have_key(:stderr)
      expect(result).to have_key(:exit_code)
    end
  end

  describe 'query generation' do
    it 'generates a valid YARD query' do
      query = validator.send(:query)
      expect(query).to be_a(String)
      expect(query).to include('docstring_text')
      expect(query).to include('unclosed_backtick')
    end

    it 'includes backtick checking logic' do
      query = validator.send(:query)
      expect(query).to include('backtick_count')
    end

    it 'includes bold formatting checking logic' do
      query = validator.send(:query)
      expect(query).to include('unclosed_bold')
    end

    it 'includes code block checking logic' do
      query = validator.send(:query)
      expect(query).to include('unclosed_code_block')
    end

    it 'includes invalid list marker detection' do
      query = validator.send(:query)
      expect(query).to include('invalid_list_marker')
    end
  end

  describe 'yard_cmd generation' do
    it 'generates a valid yard command' do
      cmd = validator.send(:yard_cmd, '/tmp/yardoc', '/tmp/files.txt')

      expect(cmd[:stdout]).to be_a(String)
      expect(cmd[:stderr]).to be_a(String)
      expect(cmd[:exit_code]).to be_a(Integer)
    end
  end
end
