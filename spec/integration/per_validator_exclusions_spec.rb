# frozen_string_literal: true

RSpec.describe 'Per-validator file exclusions', :integration, type: :feature do
  let(:fixtures_dir) { File.expand_path('fixtures', __dir__) }

  describe 'filtering files per validator' do
    it 'excludes files only for specific validators' do
      files = [
        File.join(fixtures_dir, 'missing_param_docs.rb'),
        File.join(fixtures_dir, 'undocumented_objects.rb')
      ]

      config = Yard::Lint::Config.new(
        {
          'AllValidators' => {
            'Exclude' => []
          },
          'Documentation/UndocumentedObjects' => {
            'Enabled' => true,
            'Exclude' => ['**/missing_param_docs.rb']
          },
          'Documentation/UndocumentedMethodArguments' => {
            'Enabled' => true,
            'Exclude' => ['**/undocumented_objects.rb']
          }
        }
      )

      runner = Yard::Lint::Runner.new(files, config)
      result = runner.run

      # UndocumentedObject offenses should NOT include missing_param_docs.rb
      undoc_object_offenses = result.offenses.select { |o| o[:name] == 'UndocumentedObject' }
      undoc_object_locations = undoc_object_offenses.map { |o| o[:location] }
      expect(undoc_object_locations).not_to include(
        match(/missing_param_docs\.rb/)
      )

      # UndocumentedMethodArgument offenses should NOT include undocumented_objects.rb
      undoc_arg_offenses = result.offenses.select { |o| o[:name] == 'UndocumentedMethodArgument' }
      undoc_arg_locations = undoc_arg_offenses.map { |o| o[:location] }
      expect(undoc_arg_locations).not_to include(
        match(/undocumented_objects\.rb/)
      )
    end
  end

  describe 'with glob patterns' do
    it 'supports wildcard and recursive patterns' do
      files = [
        File.join(fixtures_dir, 'yard_warnings.rb')
      ]

      config = Yard::Lint::Config.new(
        {
          'AllValidators' => { 'Exclude' => [] },
          'Warnings/UnknownTag' => {
            'Enabled' => true,
            'Exclude' => ['**/fixtures/**/*']
          }
        }
      )

      runner = Yard::Lint::Runner.new(files, config)
      result = runner.run

      # UnknownTag warnings should be empty because all files are excluded
      unknown_tag_offenses = result.offenses.select { |o| o[:name] == 'UnknownTag' }
      expect(unknown_tag_offenses).to be_empty
    end
  end

  describe 'combining global and per-validator exclusions' do
    it 'applies validator-specific exclusions independently' do
      files = [
        File.join(fixtures_dir, 'missing_param_docs.rb'),
        File.join(fixtures_dir, 'undocumented_objects.rb')
      ]

      config = Yard::Lint::Config.new(
        {
          'AllValidators' => {
            'Exclude' => []
          },
          'Documentation/UndocumentedMethodArguments' => {
            'Enabled' => true,
            'Exclude' => ['**/missing_param_docs.rb', '**/undocumented_objects.rb']
          }
        }
      )

      runner = Yard::Lint::Runner.new(files, config)
      result = runner.run

      # UndocumentedMethodArguments should not see any files
      # (both excluded by validator-specific patterns)
      undoc_arg_offenses = result.offenses.select { |o| o[:name] == 'UndocumentedMethodArgument' }
      expect(undoc_arg_offenses).to be_empty
    end
  end

  describe 'per-validator exclusions do not affect other validators' do
    it 'allows other validators to still process excluded files' do
      files = [
        File.join(fixtures_dir, 'undocumented_class.rb')
      ]

      config = Yard::Lint::Config.new(
        {
          'AllValidators' => {
            'Exclude' => []
          },
          'Documentation/UndocumentedMethodArguments' => {
            'Enabled' => true,
            'Exclude' => ['**/undocumented_class.rb']
          },
          'Documentation/UndocumentedObjects' => {
            'Enabled' => true,
            'Exclude' => []
          }
        }
      )

      runner = Yard::Lint::Runner.new(files, config)
      result = runner.run

      # UndocumentedMethodArguments should have no offenses (file excluded)
      undoc_arg_offenses = result.offenses.select { |o| o[:name] == 'UndocumentedMethodArgument' }
      expect(undoc_arg_offenses).to be_empty

      # UndocumentedObjects should still find offenses (file not excluded for this validator)
      undoc_object_offenses = result.offenses.select { |o| o[:name] == 'UndocumentedObject' }
      expect(undoc_object_offenses).not_to be_empty
    end
  end

  describe 'private methods: enforce tag order but allow undocumented' do
    it 'checks tag order on documented private methods but ignores undocumented ones' do
      files = [
        File.join(fixtures_dir, 'private_methods.rb')
      ]

      # Configuration that:
      # 1. Includes private methods in YARD parsing (--private)
      # 2. Excludes private methods from documentation validators
      # 3. Still checks tag order on private methods (if they have docs)
      config = Yard::Lint::Config.new(
        {
          'AllValidators' => {
            'YardOptions' => ['--private'],
            'Exclude' => []
          },
          # Don't require documentation on private methods
          'Documentation/UndocumentedObjects' => {
            'Enabled' => true,
            'Exclude' => ['**/private_methods.rb']
          },
          'Documentation/UndocumentedMethodArguments' => {
            'Enabled' => true,
            'Exclude' => ['**/private_methods.rb']
          },
          # But DO enforce tag order if private methods have docs
          'Tags/Order' => {
            'Enabled' => true,
            'Exclude' => []
          }
        }
      )

      runner = Yard::Lint::Runner.new(files, config)
      result = runner.run

      # Should NOT complain about undocumented private methods
      undoc_object_offenses = result.offenses.select { |o| o[:name] == 'UndocumentedObject' }
      undoc_arg_offenses = result.offenses.select { |o| o[:name] == 'UndocumentedMethodArgument' }

      expect(undoc_object_offenses).to be_empty
      expect(undoc_arg_offenses).to be_empty

      # But SHOULD enforce tag order on documented private methods
      tag_order_offenses = result.offenses.select { |o| o[:name] == 'InvalidTagOrder' }

      expect(tag_order_offenses).not_to be_empty

      # Verify it found the wrong order in documented_private_wrong_order
      # Check that at least one offense is from private_methods.rb
      private_methods_offense = tag_order_offenses.find do |o|
        o[:location].include?('private_methods.rb')
      end

      expect(private_methods_offense).not_to be_nil
      # The offense should be about documented_private_wrong_order method
      expect(private_methods_offense[:method_name]).to include('documented_private_wrong_order')
    end
  end
end
