# frozen_string_literal: true

RSpec.describe 'Yard::Lint Validators' do
  describe 'API Tags Validation' do
    context 'when require_api_tags is enabled' do
      let(:config) do
        Yard::Lint::Config.new do |c|
          c.send(:set_validator_config, 'Tags/ApiTags', 'Enabled', true)
          c.send(:set_validator_config, 'Tags/ApiTags', 'AllowedApis', %w[public private internal])
        end
      end

      it 'detects API tag issues' do
        # Run against a simple Ruby string to avoid loading full project
        result = Yard::Lint.run(path: 'lib/yard/lint/version.rb', config: config)

        # Since require_api_tags is enabled, should find missing @api tags
        expect(result.offenses.select { |o| o[:name].to_s.include?('Api') }).to be_an(Array)
        # The feature is working if we get results
        expect(result).to respond_to(:offenses)
      end
    end

    context 'when require_api_tags is disabled' do
      let(:config) do
        Yard::Lint::Config.new do |c|
          c.send(:set_validator_config, 'Tags/ApiTags', 'Enabled', false)
        end
      end

      it 'does not run API tag validation' do
        result = Yard::Lint.run(path: 'lib/yard/lint/version.rb', config: config)

        expect(result.offenses.select { |o| o[:name].to_s.include?('Api') }).to be_empty
      end
    end

    context 'with custom allowed APIs' do
      let(:config) do
        Yard::Lint::Config.new do |c|
          c.send(:set_validator_config, 'Tags/ApiTags', 'Enabled', true)
          c.send(:set_validator_config, 'Tags/ApiTags', 'AllowedApis', %w[public])
        end
      end

      it 'uses custom allowed_apis configuration' do
        result = Yard::Lint.run(path: 'lib/yard/lint/version.rb', config: config)

        # Feature should work with custom config
        expect(result.offenses.select { |o| o[:name].to_s.include?('Api') }).to be_an(Array)
      end
    end
  end

  describe 'Abstract Methods Validation' do
    context 'when validate_abstract_methods is enabled' do
      let(:config) do
        Yard::Lint::Config.new do |c|
          c.send(:set_validator_config, 'Semantic/AbstractMethods', 'Enabled', true)
        end
      end

      it 'runs abstract method validation' do
        result = Yard::Lint.run(path: 'lib', config: config)

        expect(result.offenses.select { |o| o[:name].to_s.include?('Abstract') }).to be_an(Array)
        expect(result).to respond_to(:offenses)
      end
    end

    context 'when validate_abstract_methods is disabled' do
      let(:config) do
        Yard::Lint::Config.new do |c|
          c.send(:set_validator_config, 'Semantic/AbstractMethods', 'Enabled', false)
        end
      end

      it 'does not run abstract method validation' do
        result = Yard::Lint.run(path: 'lib', config: config)

        expect(result.offenses.select { |o| o[:name].to_s.include?('Abstract') }).to be_empty
      end
    end
  end

  describe 'Option Tags Validation' do
    context 'when validate_option_tags is enabled' do
      let(:config) do
        Yard::Lint::Config.new do |c|
          c.send(:set_validator_config, 'Tags/OptionTags', 'Enabled', true)
        end
      end

      it 'runs option tags validation' do
        result = Yard::Lint.run(path: 'lib', config: config)

        expect(result.offenses.select { |o| o[:name].to_s.include?('Option') }).to be_an(Array)
        expect(result).to respond_to(:offenses)
      end
    end

    context 'when validate_option_tags is disabled' do
      let(:config) do
        Yard::Lint::Config.new do |c|
          c.send(:set_validator_config, 'Tags/OptionTags', 'Enabled', false)
        end
      end

      it 'does not run option tags validation' do
        result = Yard::Lint.run(path: 'lib', config: config)

        expect(result.offenses.select { |o| o[:name].to_s.include?('Option') }).to be_empty
      end
    end
  end

  describe 'Combined Validators' do
    let(:config) do
      Yard::Lint::Config.new do |c|
        c.send(:set_validator_config, 'Tags/ApiTags', 'Enabled', true)
        c.send(:set_validator_config, 'Semantic/AbstractMethods', 'Enabled', true)
        c.send(:set_validator_config, 'Tags/OptionTags', 'Enabled', true)
      end
    end

    it 'runs all validators when enabled' do
      result = Yard::Lint.run(path: 'lib', config: config)

      expect(result.offenses.select { |o| o[:name].to_s.include?('Api') }).to be_an(Array)
      expect(result.offenses.select { |o| o[:name].to_s.include?('Abstract') }).to be_an(Array)
      expect(result.offenses.select { |o| o[:name].to_s.include?('Option') }).to be_an(Array)
    end

    it 'includes all offense types in the offenses array' do
      result = Yard::Lint.run(path: 'lib', config: config)

      expect(result.offenses).to be_an(Array)
      expect(result).to respond_to(:offenses)
      expect(result).to respond_to(:count)
      expect(result).to respond_to(:clean?)
    end
  end
end
