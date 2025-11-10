# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'Edge case file handling' do
  let(:fixtures_dir) { File.expand_path('../fixtures', __dir__) }

  describe 'empty file' do
    it 'handles files with no code gracefully' do
      files = [File.join(fixtures_dir, 'empty_file.rb')]

      config = Yard::Lint::Config.new(
        {
          'AllValidators' => {
            'YardOptions' => [],
            'Exclude' => []
          },
          'Documentation' => {
            'Enabled' => true
          },
          'Tags/ExampleSyntax' => {
            'Enabled' => false
          }
        }
      )

      runner = Yard::Lint::Runner.new(files, config)
      result = runner.run

      # Should not crash, should have no offenses
      expect(result.offenses).to be_empty
      expect(result).to respond_to(:offenses)
    end
  end

  describe 'file with only comments' do
    it 'handles files with no executable code' do
      files = [File.join(fixtures_dir, 'only_comments.rb')]

      config = Yard::Lint::Config.new(
        {
          'AllValidators' => {
            'YardOptions' => [],
            'Exclude' => []
          },
          'Documentation' => {
            'Enabled' => true
          },
          'Tags/ExampleSyntax' => {
            'Enabled' => false
          }
        }
      )

      runner = Yard::Lint::Runner.new(files, config)
      result = runner.run

      # Should not crash, should have no offenses
      expect(result.offenses).to be_empty
      expect(result).to respond_to(:offenses)
    end
  end

  describe 'file with only require statements' do
    it 'handles files with only requires' do
      files = [File.join(fixtures_dir, 'only_requires.rb')]

      config = Yard::Lint::Config.new(
        {
          'AllValidators' => {
            'YardOptions' => [],
            'Exclude' => []
          },
          'Documentation' => {
            'Enabled' => true
          },
          'Tags/ExampleSyntax' => {
            'Enabled' => false
          }
        }
      )

      runner = Yard::Lint::Runner.new(files, config)
      result = runner.run

      # Should not crash, should have no offenses
      expect(result.offenses).to be_empty
      expect(result).to respond_to(:offenses)
    end
  end

  describe 'file with only constants' do
    it 'handles files with only constant definitions' do
      files = [File.join(fixtures_dir, 'only_constants.rb')]

      config = Yard::Lint::Config.new(
        {
          'AllValidators' => {
            'YardOptions' => [],
            'Exclude' => []
          },
          'Documentation' => {
            'Enabled' => true
          }
        }
      )

      runner = Yard::Lint::Runner.new(files, config)
      result = runner.run

      # Should not crash
      # May or may not have offenses depending on UndocumentedObject behavior
      expect(result).to respond_to(:offenses)
    end
  end

  describe 'processing multiple edge case files together' do
    it 'handles a batch of edge case files without errors' do
      files = [
        File.join(fixtures_dir, 'empty_file.rb'),
        File.join(fixtures_dir, 'only_comments.rb'),
        File.join(fixtures_dir, 'only_requires.rb'),
        File.join(fixtures_dir, 'only_constants.rb')
      ]

      config = Yard::Lint::Config.new(
        {
          'AllValidators' => {
            'YardOptions' => [],
            'Exclude' => []
          },
          'Documentation' => {
            'Enabled' => true
          },
          'Tags' => {
            'Enabled' => true
          }
        }
      )

      runner = Yard::Lint::Runner.new(files, config)
      result = runner.run

      # Should process all files without crashing
      expect(result).to respond_to(:offenses)
    end
  end

  describe 'edge case files with exclusions' do
    it 'correctly applies exclusions to edge case files' do
      files = [
        File.join(fixtures_dir, 'empty_file.rb'),
        File.join(fixtures_dir, 'only_comments.rb')
      ]

      config = Yard::Lint::Config.new(
        {
          'AllValidators' => {
            'YardOptions' => [],
            'Exclude' => ['**/empty_file.rb']
          },
          'Documentation' => {
            'Enabled' => true
          }
        }
      )

      runner = Yard::Lint::Runner.new(files, config)
      result = runner.run

      # Should only process only_comments.rb (empty_file.rb is globally excluded)
      # Verify no errors occurred
      expect(result).to respond_to(:offenses)
    end
  end

  describe 'edge case files with all validators enabled' do
    it 'runs all validators against edge case files without errors' do
      files = [
        File.join(fixtures_dir, 'empty_file.rb'),
        File.join(fixtures_dir, 'only_comments.rb'),
        File.join(fixtures_dir, 'only_requires.rb')
      ]

      config = Yard::Lint::Config.new(
        {
          'AllValidators' => {
            'YardOptions' => [],
            'Exclude' => []
          },
          'Documentation' => {
            'Enabled' => true
          },
          'Tags' => {
            'Enabled' => true
          },
          'Warnings' => {
            'Enabled' => true
          },
          'Semantic' => {
            'Enabled' => true
          }
        }
      )

      runner = Yard::Lint::Runner.new(files, config)
      result = runner.run

      # Should not crash regardless of whether offenses are found
      expect(result).to respond_to(:offenses)
    end
  end
end
