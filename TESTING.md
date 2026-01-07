# Testing Guide

This gem supports multiple Ruby and Rails versions:
- Ruby 2.7 with Rails 6.1
- Ruby 3.0 with Rails 6.1, 7.0
- Ruby 3.1 with Rails 6.1, 7.0, 7.1

## Multi-Version Testing

### Local Testing

#### Test all Ruby versions at once

Run the test suite against all supported Ruby versions:

```bash
bin/test_all
```

This script will:
- Automatically switch between Ruby versions (requires rbenv or rvm)
- Install dependencies for each version
- Run the test suite for each version
- Display a summary of results

#### Test a specific Ruby/Rails version combination

```bash
# Ruby 2.7 with Rails 6.1
export BUNDLE_GEMFILE=gemfiles/ruby_2.7_rails_6.1.gemfile
bundle install
bundle exec rake test

# Ruby 3.0 with Rails 6.1
export BUNDLE_GEMFILE=gemfiles/ruby_3.0_rails_6.1.gemfile
bundle install
bundle exec rake test

# Ruby 3.0 with Rails 7.0
export BUNDLE_GEMFILE=gemfiles/ruby_3.0_rails_7.0.gemfile
bundle install
bundle exec rake test

# Ruby 3.1 with Rails 7.1
export BUNDLE_GEMFILE=gemfiles/ruby_3.1_rails_7.1.gemfile
bundle install
bundle exec rake test
```

### Dependency Checking

Check if all dependencies are compatible with all Ruby versions:

```bash
bin/check_dependencies
```

This script will verify that all dependencies can be installed and will report any outdated gems.

## CI/CD

The gem uses GitHub Actions for continuous integration. Every push and pull request will automatically test against all supported combinations:
- Ruby 2.7 / Rails 6.1
- Ruby 3.0 / Rails 6.1, 7.0
- Ruby 3.1 / Rails 6.1, 7.0, 7.1

See `.github/workflows/ci.yml` for the full configuration.

## Gemfiles Structure

The `gemfiles/` directory contains version-specific Gemfiles for each Ruby/Rails combination:
- `ruby_2.7_rails_6.1.gemfile` - Ruby 2.7 with Rails 6.1
- `ruby_3.0_rails_6.1.gemfile` - Ruby 3.0 with Rails 6.1
- `ruby_3.0_rails_7.0.gemfile` - Ruby 3.0 with Rails 7.0
- `ruby_3.1_rails_6.1.gemfile` - Ruby 3.1 with Rails 6.1
- `ruby_3.1_rails_7.0.gemfile` - Ruby 3.1 with Rails 7.0
- `ruby_3.1_rails_7.1.gemfile` - Ruby 3.1 with Rails 7.1

Each gemfile has its own lockfile committed to the repository to ensure consistent dependency versions across environments.

## Requirements

### For Local Multi-Version Testing

You need either:
- **rbenv** with Ruby 2.7, 3.0, and 3.1 installed
- **rvm** with Ruby 2.7, 3.0, and 3.1 installed

### Installing Ruby Versions

#### Using rbenv:
```bash
rbenv install 2.7.8
rbenv install 3.0.6
rbenv install 3.1.4
```

#### Using rvm:
```bash
rvm install 2.7.8
rvm install 3.0.6
rvm install 3.1.4
```
