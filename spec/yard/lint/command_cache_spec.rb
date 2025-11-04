# frozen_string_literal: true

RSpec.describe Yard::Lint::CommandCache do
  let(:cache) { described_class.new }

  describe '#execute' do
    it 'executes a command and caches the result' do
      # First execution - cache miss
      result1 = cache.execute('echo "hello"')

      expect(result1[:stdout]).to eq("hello\n")
      expect(result1[:exit_code]).to eq(0)

      # Second execution - cache hit (same command)
      result2 = cache.execute('echo "hello"')

      expect(result2[:stdout]).to eq("hello\n")
      expect(result2[:exit_code]).to eq(0)
    end

    it 'returns different results for different commands' do
      result1 = cache.execute('echo "first"')
      result2 = cache.execute('echo "second"')

      expect(result1[:stdout]).to eq("first\n")
      expect(result2[:stdout]).to eq("second\n")
    end

    it 'handles commands with whitespace differences as identical' do
      cache.execute('echo    "test"')
      cache.execute('echo "test"')

      # Both should use the cached result
      stats = cache.stats
      expect(stats[:hits]).to eq(1)
      expect(stats[:misses]).to eq(1)
    end

    it 'deep clones results to prevent cache pollution' do
      result1 = cache.execute('echo "test"')

      # Modify the result
      result1[:stdout] = { modified: true }

      # Get cached result again
      result2 = cache.execute('echo "test"')

      # Should be the original, not modified
      expect(result2[:stdout]).to eq("test\n")
      expect(result2[:stdout]).not_to be_a(Hash)
    end

    it 'captures stderr and exit codes' do
      # Command that writes to stderr
      result = cache.execute('echo "error" >&2')

      expect(result[:stderr]).to eq("error\n")
      expect(result[:exit_code]).to eq(0)
    end
  end

  describe '#stats' do
    it 'tracks cache hits and misses' do
      cache.execute('echo "first"')  # miss
      cache.execute('echo "first"')  # hit
      cache.execute('echo "second"') # miss
      cache.execute('echo "first"')  # hit

      stats = cache.stats

      expect(stats[:hits]).to eq(2)
      expect(stats[:misses]).to eq(2)
      expect(stats[:total]).to eq(4)
      expect(stats[:saved_executions]).to eq(2)
    end

    it 'starts with zero hits and misses' do
      stats = cache.stats

      expect(stats[:hits]).to eq(0)
      expect(stats[:misses]).to eq(0)
      expect(stats[:total]).to eq(0)
    end
  end

  describe 'command normalization' do
    it 'treats commands with different whitespace as identical' do
      cache.execute("echo   'test'  ")
      cache.execute("echo 'test'")
      cache.execute("echo    'test'")

      stats = cache.stats
      expect(stats[:hits]).to eq(2)  # Second and third are hits
      expect(stats[:misses]).to eq(1) # Only first is a miss
    end

    it 'treats commands with newlines as identical to single-line' do
      cache.execute("echo \n 'test'")
      cache.execute("echo 'test'")

      stats = cache.stats
      expect(stats[:hits]).to eq(1)
      expect(stats[:misses]).to eq(1)
    end
  end

  describe 'deep cloning' do
    it 'prevents modifications to nested hash structures' do
      # Execute a command
      result1 = cache.execute('echo "test"')

      # Modify stdout to be a nested hash (like Tags/Order does)
      result1[:stdout] = { result: 'test', nested: { data: 'value' } }
      result1[:stdout][:nested][:data] = 'modified'

      # Get from cache again
      result2 = cache.execute('echo "test"')

      # Should be original string, not modified hash
      expect(result2[:stdout]).to eq("test\n")
    end
  end
end
