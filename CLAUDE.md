# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

YARD-Lint is a comprehensive linter for YARD documentation in Ruby projects. It validates YARD documentation for undocumented code, missing parameter documentation, invalid tag types, incorrect tag ordering, boolean method documentation, API tag validation, abstract method validation, and option hash documentation.

## Development Commands

### Testing
```bash
# Run all tests
bundle exec rspec

# Run a single test file
bundle exec rspec spec/path/to/spec_file.rb

# Run a specific test
bundle exec rspec spec/path/to/spec_file.rb:line_number
```

### Running YARD-Lint
```bash
# Lint the lib directory
bundle exec exe/yard-lint lib/

# Lint with custom config
bundle exec exe/yard-lint --config .yard-lint.yml lib/

# Lint with specific options
bundle exec exe/yard-lint --tags-order param,return,raise lib/
```

### Development Console
```bash
# Start an IRB console with the gem loaded
bin/console
```

### Installation
```bash
# Install dependencies
bundle install

# Setup development environment
bin/setup
```

## Architecture

### Core Components

**Entry Point (`Yard::Lint`)**
- Main module in `lib/yard/lint.rb`
- Uses Zeitwerk for autoloading
- Provides `Yard::Lint.run(path:, config:, config_file:)` as the primary API
- Handles path expansion and file exclusion

**Configuration (`Yard::Lint::Config`)**
- Located in `lib/yard/lint/config.rb`
- Manages all configuration options (tags_order, extra_types, exclude patterns, etc.)
- Supports loading from `.yard-lint.yml` with automatic upward directory search
- Can be instantiated programmatically or loaded from file

**Runner (`Yard::Lint::Runner`)**
- Located in `lib/yard/lint/runner.rb`
- Orchestrates the validation process
- Runs all validators based on configuration
- Collects and parses results from all validators
- Returns a `Result` object

**Result (`Yard::Lint::Result`)**
- Located in `lib/yard/lint/result.rb`
- Contains all offenses found during validation
- Provides methods for accessing offenses by category
- Calculates statistics and exit codes based on severity

### Validator Architecture

**Base Validator (`Yard::Lint::Validators::Base`)**
- Located in `lib/yard/lint/validators/base.rb`
- All validators inherit from this base class
- Executes YARD commands via shell using `Open3.capture3`
- Uses a shared temporary directory (`YARDOC_TEMP_DIR`) for YARD database to avoid rebuilding
- Returns raw hash with stdout, stderr, and exit_code

**Validator Types:**
- `Stats` - Runs YARD stats to collect warnings
- `UndocumentedMethodArguments` - Finds methods with undocumented parameters
- `InvalidTagsTypes` - Validates tag type definitions
- `InvalidTagsOrder` - Checks tag ordering
- `UndocumentedBooleanMethods` - Validates question mark methods
- `ApiTags` - Optional validator for @api tag enforcement (opt-in via config)
- `AbstractMethods` - Optional validator for @abstract methods (enabled by default)
- `OptionTags` - Optional validator for @option tags (enabled by default)

### Parser Architecture

**Base Parser (`Yard::Lint::Parsers::Base`)**
- Located in `lib/yard/lint/parsers/base.rb`
- All parsers inherit from this base class
- Uses class-level `regexps` accessor for pattern definitions
- Provides `match(string, regexp_name)` method for extraction

**Parser Types:**
- Warning parsers: `UnknownTag`, `UnknownDirective`, `InvalidTagFormat`, etc.
- Object parsers: `UndocumentedObject`, `UndocumentedMethodArguments`
- Validation parsers: `InvalidTagsOrder`, `ApiTags`, `AbstractMethods`, `OptionTags`

### Data Flow

1. `Yard::Lint.run` receives path and config
2. Files are expanded and filtered based on exclusion patterns
3. `Runner` instantiates and runs all validators
4. Each validator executes YARD commands and returns raw output
5. Runner parses raw output using parser classes
6. Parsed results are organized into a `Result` object
7. Result provides offense data with severity levels

### Offense Structure

All offenses follow this structure:
```ruby
{
  severity: 'error' | 'warning' | 'convention',
  type: 'line' | 'method',
  name: 'OffenseName',
  message: 'Description of the offense',
  location: 'path/to/file.rb',
  location_line: 42
}
```

### Configuration Priority

Configuration is loaded in this order (highest to lowest priority):
1. Command-line options
2. `.yard-lint.yml` file (auto-discovered by searching upward)
3. Default values in `Config` class

### Code Style

- Ruby 3.2+ required
- Frozen string literals enabled
- Double quotes for strings preferred
- YARD documentation required for all public methods
- This project dogfoods itself - it uses yard-lint to validate its own documentation
