# frozen_string_literal: true

RSpec.describe Yard::Lint::Runner do
  let(:selection) { ['lib/example.rb'] }
  let(:config) { Yard::Lint::Config.new }
  let(:runner) { described_class.new(selection, config) }

  describe '#initialize' do
    it 'stores selection as array' do
      expect(runner.selection).to eq(['lib/example.rb'])
    end

    it 'flattens nested arrays in selection' do
      nested_runner = described_class.new([['file1.rb'], 'file2.rb'], config)
      expect(nested_runner.selection).to eq(['file1.rb', 'file2.rb'])
    end

    it 'stores config' do
      expect(runner.config).to eq(config)
    end

    it 'uses default config when none provided' do
      default_runner = described_class.new(selection)
      expect(default_runner.config).to be_a(Yard::Lint::Config)
    end

    it 'creates result builder with config' do
      expect(runner.instance_variable_get(:@result_builder)).to be_a(Yard::Lint::ResultBuilder)
    end
  end

  describe '#run' do
    it 'returns an aggregate result object' do
      result = runner.run
      expect(result).to be_a(Yard::Lint::Results::Aggregate)
    end

    it 'orchestrates the validation process' do
      allow(runner).to receive(:run_validators).and_call_original
      allow(runner).to receive(:parse_results).and_call_original
      allow(runner).to receive(:build_result).and_call_original
      runner.run
      expect(runner).to have_received(:run_validators)
      expect(runner).to have_received(:parse_results)
      expect(runner).to have_received(:build_result)
    end
  end

  describe '#filter_files_for_validator' do
    let(:files) do
      [
        'lib/foo.rb',
        'lib/bar.rb',
        'lib/baz/qux.rb',
        'spec/foo_spec.rb',
        'app/models/user.rb'
      ]
    end

    it 'returns all files when validator has no exclusions' do
      allow(config).to receive(:validator_exclude).with('Some/Validator').and_return([])

      result = runner.send(:filter_files_for_validator, 'Some/Validator', files)

      expect(result).to eq(files)
    end

    it 'filters files matching validator exclude patterns' do
      allow(config).to receive(:validator_exclude)
        .with('Some/Validator')
        .and_return(['spec/**/*'])

      result = runner.send(:filter_files_for_validator, 'Some/Validator', files)

      expect(result).to eq(
        [
          'lib/foo.rb',
          'lib/bar.rb',
          'lib/baz/qux.rb',
          'app/models/user.rb'
        ]
      )
    end

    it 'supports glob patterns with ** and *' do
      allow(config).to receive(:validator_exclude)
        .with('Some/Validator')
        .and_return(['lib/**/*.rb'])

      result = runner.send(:filter_files_for_validator, 'Some/Validator', files)

      expect(result).to eq(['spec/foo_spec.rb', 'app/models/user.rb'])
    end

    it 'handles multiple exclusion patterns' do
      allow(config).to receive(:validator_exclude)
        .with('Some/Validator')
        .and_return(['spec/**/*', 'app/**/*'])

      result = runner.send(:filter_files_for_validator, 'Some/Validator', files)

      expect(result).to eq(
        [
          'lib/foo.rb',
          'lib/bar.rb',
          'lib/baz/qux.rb'
        ]
      )
    end

    it 'supports simple wildcard patterns' do
      allow(config).to receive(:validator_exclude)
        .with('Some/Validator')
        .and_return(['lib/ba*.rb'])

      result = runner.send(:filter_files_for_validator, 'Some/Validator', files)

      expect(result).to eq(
        [
          'lib/foo.rb',
          'lib/baz/qux.rb',
          'spec/foo_spec.rb',
          'app/models/user.rb'
        ]
      )
    end

    it 'returns empty array when all files are excluded' do
      allow(config).to receive(:validator_exclude)
        .with('Some/Validator')
        .and_return(['**/*'])

      result = runner.send(:filter_files_for_validator, 'Some/Validator', files)

      expect(result).to eq([])
    end
  end

  describe 'integration' do
    it 'processes enabled validators only' do
      custom_config = Yard::Lint::Config.new
      allow(custom_config).to receive(:validator_enabled?).and_return(false)
      runner = described_class.new(selection, custom_config)

      result = runner.run
      expect(result.count).to eq(0)
    end
  end
end
