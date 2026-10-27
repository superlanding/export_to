# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `CHANGELOG.md`.
- Full `README.md`: overview, requirements, installation, DSL usage, development and release flow.
- CLAUDE.md rule: every PR must also update `README.md` and `CHANGELOG.md`.

## [1.3.0] - 2026-10-27

### Fixed

- `ExportTo::Base#each` raised `NoMethodError (undefined method 'rows!')` on every call. It now returns an Array of all rows (header row first, same content as `#to_csv`); with a block it yields each row and returns the exporter, so Enumerable methods (`map`, `to_a`, ...) work too. `#each!` is unchanged.
- `TESTING.md` and `bin/test_all` were stale (Ruby 2.7–3.1 only). They now describe and run the same matrix as `.github/workflows/ci.yml`.

### Deprecated

- `ExportTo::Base#to_xls`: it has returned **XLSX** data (same as `#to_xlsx`) since 1.0.0, not a legacy `.xls` file. The return value is unchanged to avoid breaking callers, but it now prints a one-time `[DEPRECATION]` warning (to `$stderr`, once per process). Use `#to_xlsx`; for a real `.xls` use `ExportTo::Exporter::Xls.new(export).to_xls`. A future major version may make `#to_xls` return a real `.xls` file or remove it.

### Added

- Tests: `#each`, `#to_xls` compatibility (still XLSX) and its deprecation warning, `#to_xlsx` / `ExportTo::Exporter::Xls` output formats.

## [1.2.1] - 2026-10-27

### Added

- Support for Rails 8.0 / 8.1 and Ruby 3.4 (`activesupport` is now allowed up to `< 8.2`; the `csv` gem is an explicit dependency; the `required_ruby_version` upper bound is removed; new `ruby_3.3_rails_8.*` / `ruby_3.4_rails_8.*` gemfiles and CI jobs).
- GitHub Actions `publish.yml`: a new version on `master` is published to RubyGems through Trusted Publishing.
- CLAUDE.md release rules.

### Changed

- Removed stale per-gemfile lockfiles that broke older Rubies in CI.

## [1.2.0] - 2026-01-08

### Added

- Ruby 3.2 and 3.3 test gemfiles (`ruby_3.2_rails_7.0`, `ruby_3.2_rails_7.1`, `ruby_3.3_rails_7.1`) and CI jobs.

### Changed

- Gemspec `required_ruby_version` upper bound raised from `< 3.2.0` to `< 3.4.0`.

## [1.1.2] - 2026-01-07

### Changed

- Updated gemfile lockfiles.

## [1.1.1] - 2026-01-07

### Added

- Multi-version Ruby / Rails test setup: per-version gemfiles, GitHub Actions matrix, `bin/test_all`, `bin/check_dependencies` and `TESTING.md`.

### Fixed

- A test no longer depends on a hard-coded macOS path.

## [1.1.0] - 2023-02-02

### Changed

- XLSX exporter fixes and tweaks (`ExportTo::Exporter::Xlsx`).

## [1.0.0] - 2023-02-02

### Changed

- Rewrite of the internals: export logic moved into `ExportTo::Exporter::Csv` / `Xls` / `Xlsx`; `ExportTo::Base` exposes `to_csv`, `to_xlsx` and `to_xls`.
- `activesupport` is now constrained to `>= 6, < 7`; development dependencies relaxed to `bundler >= 2.0`, `rake >= 13`.

## [0.1.2] - 2019-06-19

### Changed

- CSV output now force-quotes every field.

## [0.1.1] - 2018-12-05

### Fixed

- "File exists" bug when exporting.

## [0.1.0] - 2018-10-21

### Added

- Initial release: `ExportTo::Base` DSL (`set`, `joins`, `presenter`, `each_with`), presenters with row counters, empty join relations, `to_xlsx`.

[Unreleased]: https://github.com/superlanding/export_to/compare/v1.3.0...HEAD
[1.3.0]: https://github.com/superlanding/export_to/compare/v1.2.1...v1.3.0
[1.2.1]: https://github.com/superlanding/export_to/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/superlanding/export_to/compare/v1.1.2...v1.2.0
[1.1.2]: https://github.com/superlanding/export_to/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/superlanding/export_to/releases/tag/v1.1.1
[1.1.0]: https://github.com/superlanding/export_to/commit/48957da
[1.0.0]: https://github.com/superlanding/export_to/commit/8d7f937
[0.1.2]: https://github.com/superlanding/export_to/commit/d276482
[0.1.1]: https://github.com/superlanding/export_to/commit/12dd5c1
[0.1.0]: https://github.com/superlanding/export_to/commit/d605bf9
