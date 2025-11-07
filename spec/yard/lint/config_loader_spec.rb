# frozen_string_literal: true

RSpec.describe Yard::Lint::ConfigLoader do
  describe '.load' do
    it 'loads a configuration file' do
      config_dir = File.expand_path('../../../fixtures', __dir__)
      FileUtils.mkdir_p(config_dir)
      config_path = File.join(config_dir, 'basic_config.yml')
      File.write(config_path, "AllValidators:\n  Exclude:\n    - 'vendor/**/*'")

      config = described_class.load(config_path)

      expect(config).to be_a(Hash)
      expect(config['AllValidators']['Exclude']).to eq(['vendor/**/*'])

      File.delete(config_path)
    end
  end

  describe '.validator_module' do
    it 'returns the correct module for Tags/Order' do
      expect(described_class.validator_module('Tags/Order')).to eq(Yard::Lint::Validators::Tags::Order)
    end

    it 'returns the correct module for Tags/InvalidTypes' do
      expect(described_class.validator_module('Tags/InvalidTypes')).to eq(Yard::Lint::Validators::Tags::InvalidTypes)
    end

    it 'returns the correct module for Tags/ApiTags' do
      expect(described_class.validator_module('Tags/ApiTags')).to eq(Yard::Lint::Validators::Tags::ApiTags)
    end

    it 'returns the correct module for Documentation/UndocumentedMethodArguments' do
      expect(described_class.validator_module('Documentation/UndocumentedMethodArguments'))
        .to eq(Yard::Lint::Validators::Documentation::UndocumentedMethodArguments)
    end

    it 'returns the correct module for Semantic/AbstractMethods' do
      expect(described_class.validator_module('Semantic/AbstractMethods'))
        .to eq(Yard::Lint::Validators::Semantic::AbstractMethods)
    end

    it 'returns the correct module for Warnings/UnknownTag' do
      expect(described_class.validator_module('Warnings/UnknownTag')).to eq(Yard::Lint::Validators::Warnings::UnknownTag)
    end

    it 'returns the correct module for Documentation/UndocumentedObjects' do
      expect(described_class.validator_module('Documentation/UndocumentedObjects'))
        .to eq(Yard::Lint::Validators::Documentation::UndocumentedObjects)
    end

    it 'returns nil for non-existent validators' do
      expect(described_class.validator_module('Tags/NonExistent')).to be_nil
    end
  end

  describe '#load' do
    let(:config_dir) { File.expand_path('../../../fixtures', __dir__) }
    let(:config_path) { File.join(config_dir, 'test_config.yml') }

    before do
      FileUtils.mkdir_p(config_dir)
    end

    after do
      FileUtils.rm_f(config_path)
    end

    it 'loads a simple configuration' do
      File.write(config_path, <<~YAML)
        AllValidators:
          Exclude:
            - 'test/**/*'
      YAML

      loader = described_class.new(config_path)
      config = loader.load

      expect(config['AllValidators']['Exclude']).to eq(['test/**/*'])
    end

    it 'handles empty configuration files' do
      File.write(config_path, '')

      loader = described_class.new(config_path)
      config = loader.load

      expect(config).to eq({})
    end

    it 'merges inherited configurations with inherit_from' do
      base_config_path = File.join(config_dir, 'base_config.yml')
      File.write(base_config_path, <<~YAML)
        AllValidators:
          Exclude:
            - 'base/**/*'
      YAML

      File.write(config_path, <<~YAML)
        inherit_from: base_config.yml
        AllValidators:
          FailOnSeverity: error
      YAML

      loader = described_class.new(config_path)
      config = loader.load

      expect(config['AllValidators']['Exclude']).to eq(['base/**/*'])
      expect(config['AllValidators']['FailOnSeverity']).to eq('error')

      FileUtils.rm_f(base_config_path)
    end

    it 'handles multiple inherited files with inherit_from' do
      base1_path = File.join(config_dir, 'base1.yml')
      base2_path = File.join(config_dir, 'base2.yml')

      File.write(base1_path, <<~YAML)
        Tags/Order:
          Enabled: false
      YAML

      File.write(base2_path, <<~YAML)
        Tags/InvalidTypes:
          Enabled: false
      YAML

      File.write(config_path, <<~YAML)
        inherit_from:
          - base1.yml
          - base2.yml
      YAML

      loader = described_class.new(config_path)
      config = loader.load

      expect(config['Tags/Order']['Enabled']).to be false
      expect(config['Tags/InvalidTypes']['Enabled']).to be false

      FileUtils.rm_f([base1_path, base2_path])
    end

    it 'raises error on circular dependencies' do
      circular1_path = File.join(config_dir, 'circular1.yml')
      circular2_path = File.join(config_dir, 'circular2.yml')

      File.write(circular1_path, <<~YAML)
        inherit_from: circular2.yml
      YAML

      File.write(circular2_path, <<~YAML)
        inherit_from: circular1.yml
      YAML

      loader = described_class.new(circular1_path)

      expect { loader.load }.to raise_error(Yard::Lint::Errors::CircularDependencyError)

      FileUtils.rm_f([circular1_path, circular2_path])
    end

    it 'overrides inherited array values completely' do
      base_config_path = File.join(config_dir, 'base_config.yml')
      File.write(base_config_path, <<~YAML)
        AllValidators:
          Exclude:
            - 'vendor/**/*'
            - 'node_modules/**/*'
      YAML

      File.write(config_path, <<~YAML)
        inherit_from: base_config.yml
        AllValidators:
          Exclude:
            - 'test/**/*'
      YAML

      loader = described_class.new(config_path)
      config = loader.load

      # Arrays should be completely replaced, not merged
      expect(config['AllValidators']['Exclude']).to eq(['test/**/*'])

      FileUtils.rm_f(base_config_path)
    end

    it 'merges hash values deeply' do
      base_config_path = File.join(config_dir, 'base_config.yml')
      File.write(base_config_path, <<~YAML)
        Tags/Order:
          Enabled: true
          Severity: convention
      YAML

      File.write(config_path, <<~YAML)
        inherit_from: base_config.yml
        Tags/Order:
          Severity: warning
      YAML

      loader = described_class.new(config_path)
      config = loader.load

      expect(config['Tags/Order']['Enabled']).to be true
      expect(config['Tags/Order']['Severity']).to eq('warning')

      FileUtils.rm_f(base_config_path)
    end

    it 'skips non-existent inherited files' do
      File.write(config_path, <<~YAML)
        inherit_from: non_existent.yml
        AllValidators:
          FailOnSeverity: error
      YAML

      loader = described_class.new(config_path)
      config = loader.load

      expect(config['AllValidators']['FailOnSeverity']).to eq('error')
    end
  end

  describe 'gem inheritance' do
    let(:config_dir) { File.expand_path('../../../fixtures', __dir__) }
    let(:config_path) { File.join(config_dir, 'test_gem_config.yml') }

    before do
      FileUtils.mkdir_p(config_dir)
    end

    after do
      FileUtils.rm_f(config_path)
    end

    it 'handles missing gems gracefully' do
      File.write(config_path, <<~YAML)
        inherit_gem:
          non_existent_gem: config.yml
      YAML

      loader = described_class.new(config_path)

      expect { loader.load }.not_to raise_error
    end
  end

  describe 'merge behavior' do
    let(:config_dir) { File.expand_path('../../../fixtures', __dir__) }
    let(:config_path) { File.join(config_dir, 'merge_test.yml') }

    before do
      FileUtils.mkdir_p(config_dir)
    end

    after do
      FileUtils.rm_f(config_path)
    end

    it 'does not include inherit_from in merged config' do
      File.write(config_path, <<~YAML)
        inherit_from: base.yml
        AllValidators:
          Exclude:
            - 'test/**/*'
      YAML

      loader = described_class.new(config_path)
      config = loader.load

      expect(config.key?('inherit_from')).to be false
    end

    it 'does not include inherit_gem in merged config' do
      File.write(config_path, <<~YAML)
        inherit_gem:
          some_gem: config.yml
        AllValidators:
          Exclude:
            - 'test/**/*'
      YAML

      loader = described_class.new(config_path)
      config = loader.load

      expect(config.key?('inherit_gem')).to be false
    end

    it 'merges scalar values by overriding' do
      base_config_path = File.join(config_dir, 'scalar_base.yml')
      File.write(base_config_path, <<~YAML)
        AllValidators:
          FailOnSeverity: warning
      YAML

      File.write(config_path, <<~YAML)
        inherit_from: scalar_base.yml
        AllValidators:
          FailOnSeverity: error
      YAML

      loader = described_class.new(config_path)
      config = loader.load

      expect(config['AllValidators']['FailOnSeverity']).to eq('error')

      FileUtils.rm_f(base_config_path)
    end
  end
end
