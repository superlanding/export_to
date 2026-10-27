# Testing Guide

Tests use Minitest + shoulda-context (`test/**/*_test.rb`) and run against several Ruby / Rails combinations.

The supported matrix is defined in **one place**: [`.github/workflows/ci.yml`](.github/workflows/ci.yml). Each combination has a gemfile `gemfiles/ruby_<ruby>_rails_<rails>.gemfile`. Lists of versions are intentionally not copied here so they cannot go stale; see the [README](README.md#requirements) for the current table.

## Run the tests for one combination

CI selects the gemfile with `BUNDLE_GEMFILE`; do the same locally (switch to the matching Ruby first, e.g. with rbenv):

```bash
export BUNDLE_GEMFILE=$PWD/gemfiles/ruby_3.4_rails_8.1.gemfile
bundle install
bundle exec rake test       # also: rake t / rake
```

## Run the whole CI matrix locally

```bash
bin/test_all
```

`bin/test_all` needs rbenv or rvm. For every entry of its `TEST_MATRIX` (kept equal to the CI matrix) it switches to the newest installed patch version of that Ruby, runs `bundle install` with the matching gemfile, runs `rake test` and prints a summary. A Ruby that is not installed is reported as a failure. When you change `ci.yml`, update `TEST_MATRIX` in `bin/test_all` as well.

## Check dependencies

```bash
bin/check_dependencies
```

Verifies that the dependencies can be installed for the supported versions and reports outdated gems.

## Adding a Ruby / Rails combination

1. Add `gemfiles/ruby_<ruby>_rails_<rails>.gemfile` (copy a neighbouring one and change the `activesupport` / `railties` versions).
2. Add the combination to the matrix in `.github/workflows/ci.yml` and to `TEST_MATRIX` in `bin/test_all`.
3. Update the table in the README.

## Lockfiles

Some gemfiles have a committed `*.gemfile.lock`, and `Gemfile.lock` is committed too. They contain the gem's own version (`export_to (x.y.z)`), so **keep them consistent: bump the version in those files whenever `lib/export_to/version.rb` changes**.

## CI

GitHub Actions runs every matrix entry on every push to `master` and on every pull request that targets `master`.
