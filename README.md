# YARD-Lint

A comprehensive linter for YARD documentation that helps you maintain clean, consistent, and complete documentation in your Ruby projects.

## Features

YARD-Lint validates your YARD documentation for:

- **Undocumented code**: Classes, modules, methods, and constants without documentation
- **Missing parameter documentation**: Methods with undocumented parameters
- **Invalid tag types**: Type definitions that aren't valid Ruby classes or allowed defaults
- **Invalid tag ordering**: Tags that don't follow your specified order
- **Boolean method documentation**: Question mark methods missing return type documentation
- **API tag validation**: Enforce @api tags on public objects and validate API values
- **Abstract method validation**: Ensure @abstract methods don't have real implementations
- **Option hash documentation**: Validate that methods with options parameters have @option tags
- **YARD warnings**: Unknown tags, invalid directives, duplicated parameter names, and more

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yard-lint'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install yard-lint
```

## Usage

### Command Line

Basic usage:

```bash
yard-lint lib/**/*.rb
```

With custom options:

```bash
# Specify tag ordering
yard-lint --tags-order param,return,raise lib/

# Add extra allowed types
yard-lint --extra-types CustomType,AnotherType lib/

# Output as JSON
yard-lint --format json lib/ > report.json
```

### Ruby API

```ruby
require 'yard/lint'

# Simple usage
result = Yard::Lint.run(path: 'lib/**/*.rb')

if result.clean?
  puts "No offenses found!"
else
  puts "Found #{result.count} offenses:"
  result.offenses.each do |offense|
    puts "#{offense[:location]}:#{offense[:location_line]}"
    puts "  #{offense[:severity]}: #{offense[:message]}"
  end
end

# With custom configuration
config = Yard::Lint::Config.new do |c|
  c.tags_order = ['param', 'option', 'return', 'raise']
  c.extra_types = ['CustomType']
  c.invalid_tags_names = ['param', 'return']
  c.options = ['--private', '--protected']
end

result = Yard::Lint.run(path: 'lib/', config: config)
```

## Configuration

YARD-Lint can be configured in three ways (in order of precedence):

1. **Command-line options** (highest priority)
2. **Configuration file** (`.yard-lint.yml`)
3. **Defaults** (lowest priority)

### Configuration File

Create a `.yard-lint.yml` file in your project root:

```yaml
# .yard-lint.yml
tags_order:
  - param
  - option
  - yield
  - yieldparam
  - yieldreturn
  - return
  - raise
  - see
  - example
  - note
  - todo

invalid_tags_names:
  - param
  - option
  - return
  - yieldreturn

extra_types:
  - CustomType
  - MyType

options:
  - --private
  - --protected

exclude:
  - '\.git'
  - 'vendor/**/*'
  - 'node_modules/**/*'
  - 'spec/**/*'

fail_on_severity: warning

# Optional validators
require_api_tags: false  # Disabled by default (opt-in)
allowed_apis:
  - public
  - private
  - internal

# Enabled by default for better documentation quality
validate_abstract_methods: true
validate_option_tags: true
```

YARD-Lint will automatically search for `.yard-lint.yml` in the current directory and parent directories.

You can specify a different config file:

```bash
yard-lint --config path/to/config.yml lib/
```

### Ruby API Configuration

You can also configure YARD-Lint programmatically:

```ruby
# Load from file
config = Yard::Lint::Config.from_file('.yard-lint.yml')

# Or configure in Ruby
config = Yard::Lint::Config.new do |c|
  c.tags_order = ['param', 'return', 'raise', 'example']
  c.extra_types = ['CustomType', 'MyEnum']
  c.options = ['--private', '--protected']
end

result = Yard::Lint.run(path: 'lib/', config: config)
```

### Configuration Options

#### tags_order

Specifies the expected order of YARD tags. Defaults to:

```ruby
['param', 'option', 'yield', 'yieldparam', 'yieldreturn', 'return', 'raise', 'see', 'example', 'note', 'todo']
```

#### invalid_tags_names

Tags to check for invalid type definitions. Defaults to:

```ruby
['param', 'option', 'return', 'yieldreturn']
```

#### extra_types

Additional type names to allow (beyond Ruby built-in types and defined constants). Defaults to:

```ruby
[]
```

#### options

Extra options to pass to YARD commands. Defaults to:

```ruby
[]
```

#### exclude

File patterns to exclude from linting. Defaults to:

```ruby
['\.git', 'vendor/**/*', 'node_modules/**/*']
```

Supports glob patterns compatible with `File.fnmatch`.

#### fail_on_severity

Severity level at which to exit with error code. Valid values:

- `"error"` - Only fail on errors
- `"warning"` - Fail on errors and warnings (default)
- `"convention"` - Fail on any offense
- `"never"` - Never fail (always exit 0)

Defaults to:

```ruby
'warning'
```

#### require_api_tags

When enabled, validates that all public objects have an `@api` tag. Defaults to `false`.

```ruby
false
```

#### allowed_apis

List of allowed values for `@api` tags. Only checked when `require_api_tags` is true. Defaults to:

```ruby
['public', 'private', 'internal']
```

#### validate_abstract_methods

When enabled, validates that methods marked with `@abstract` don't have real implementations (they should only raise `NotImplementedError` or be empty). **Enabled by default** for better documentation quality. Set to `false` to disable.

```ruby
true  # Default
```

#### validate_option_tags

When enabled, validates that methods with `options`, `opts`, or `kwargs` parameters have corresponding `@option` tags documenting the available options. **Enabled by default** for better documentation quality. Set to `false` to disable.

```ruby
true  # Default
```

## Result Object

The `Yard::Lint::Result` object provides several methods:

```ruby
result = Yard::Lint.run(path: 'lib/')

result.offenses         # Array of all offenses
result.count            # Total offense count
result.offenses?        # True if there are offenses
result.clean?           # True if no offenses
result.statistics       # Hash with counts by severity
result.exit_code(config) # Exit code based on config

# Access specific offense categories
result.warnings                         # YARD parser warnings
result.undocumented                     # Undocumented objects
result.undocumented_method_arguments    # Methods with missing param docs
result.invalid_tags_types               # Invalid type definitions
result.invalid_tags_order               # Tags in wrong order
result.api_tags                         # Missing or invalid @api tags
result.abstract_methods                 # @abstract methods with implementation
result.option_tags                      # Missing @option tags for options parameters
```

## Offense Structure

Each offense is a hash with the following structure:

```ruby
{
  severity: 'error' | 'warning' | 'convention',
  type: 'line' | 'method',
  name: 'UnknownTag',  # Offense name
  message: 'Unknown tag @example1...',
  location: 'lib/my_class.rb',
  location_line: 32
}
```

### Severity Levels

- **error**: Critical issues (unknown tags, invalid formats, etc.)
- **warning**: Missing documentation, invalid type definitions
- **convention**: Style issues (tag ordering)

## Integration with CI

### GitHub Actions

```yaml
- name: Run YARD Lint
  run: |
    bundle exec yard-lint lib/
```

### With RuboCop

You can run YARD-Lint alongside RuboCop in your CI pipeline:

```yaml
- name: Run Linters
  run: |
    bundle exec rubocop
    bundle exec yard-lint lib/
```

## CLI Options

YARD-Lint supports the following command-line options:

```bash
yard-lint [options] PATH

Options:
  -c, --config FILE                Path to config file (default: .yard-lint.yml)
  -t, --tags-order ORDER           Comma-separated list of tag names in expected order
  -e, --extra-types TYPES          Comma-separated list of extra allowed type names
  -o, --options OPTIONS            Comma-separated list of extra YARD options
  -x, --exclude PATTERNS           Comma-separated list of exclusion patterns
  -s, --fail-on-severity LEVEL     Fail on severity level (error, warning, convention, never)
  -f, --format FORMAT              Output format (text, json)
  -q, --quiet                      Quiet mode (only show summary)
      --stats                      Show statistics summary
  -v, --version                    Show version
  -h, --help                       Show this help
```

## Examples

### Check a single file

```bash
yard-lint lib/my_class.rb
```

### Check multiple paths

```bash
yard-lint lib/ app/
```

### Quiet mode with statistics

```bash
yard-lint --quiet --stats lib/
```

### Only fail on errors

```bash
yard-lint --fail-on-severity error lib/
```

### Exclude specific patterns

```bash
yard-lint --exclude 'lib/generated/**/*,spec/**/*' lib/
```

### Enable @api tag validation

```bash
yard-lint --config .yard-lint.yml lib/
```

With `.yard-lint.yml`:
```yaml
require_api_tags: true
allowed_apis:
  - public
  - private
```

This will enforce that all public classes, modules, and methods have an `@api` tag:

```ruby
# Good
# @api public
class MyClass
  # @api public
  def public_method
  end

  # @api private
  def internal_helper
  end
end

# Bad - missing @api tags
class AnotherClass
  def some_method
  end
end
```

### @abstract method validation (enabled by default)

This validator ensures abstract methods don't have real implementations. It's **enabled by default**. To disable it, set:

```yaml
validate_abstract_methods: false
```

Examples:

```ruby
# Good
# @abstract
def process
  raise NotImplementedError
end

# Bad - @abstract method has implementation
# @abstract
def process
  puts "This shouldn't be here"
  do_something
end
```

### @option tag validation (enabled by default)

This validator ensures that methods with options parameters document them. It's **enabled by default**. To disable it, set:

```yaml
validate_option_tags: false
```

Examples:

```ruby
# Good
# @param name [String] the name
# @param options [Hash] configuration options
# @option options [Boolean] :enabled Whether to enable the feature
# @option options [Integer] :timeout Timeout in seconds
def configure(name, options = {})
end

# Bad - missing @option tags
# @param name [String] the name
# @param options [Hash] configuration options
def configure(name, options = {})
end
```

### Use in a Rake task

```ruby
# Rakefile
require 'yard/lint/rake_task'

Yard::Lint::RakeTask.new do |task|
  task.paths = ['lib']
  task.config_file = '.yard-lint.yml'
  task.fail_on_error = true
end
```

Or manually:

```ruby
# Rakefile
require 'yard/lint'

desc 'Run YARD lint'
task :yard_lint do
  result = Yard::Lint.run(path: 'lib/**/*.rb')

  unless result.clean?
    puts "YARD lint failed with #{result.count} offenses"
    exit 1
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes in each version.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mensfeld/yard-lint.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

This gem was extracted from the [OffendingEngine](https://github.com/coditsu/offending-engine) project by Maciej Mensfeld.
