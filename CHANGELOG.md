# 更新紀錄（Changelog）

本檔記錄此專案所有值得注意的變更。

格式參考 [Keep a Changelog](https://keepachangelog.com/zh-TW/1.1.0/)，版本號遵循 [Semantic Versioning](https://semver.org/lang/zh-TW/)。

## [Unreleased]

### Added

- 新增 `CHANGELOG.md`。
- 完整的 `README.md`：概述、環境需求、安裝、DSL 用法、開發與發版流程。
- CLAUDE.md 規則：每個 PR 都必須同步更新 `README.md` 與 `CHANGELOG.md`；`README.md` 與 `CHANGELOG.md` 一律用繁體中文撰寫。

### Changed

- `README.md`、`CHANGELOG.md` 改以繁體中文（zh-TW）撰寫。

## [1.2.1] - 2026-10-27

### Added

- 支援 Rails 8.0 / 8.1 與 Ruby 3.4（`activesupport` 現在放寬到 `< 8.2`；`csv` gem 改為明確相依；移除 `required_ruby_version` 的上限；新增 `ruby_3.3_rails_8.*` / `ruby_3.4_rails_8.*` gemfile 與對應的 CI job）。
- GitHub Actions `publish.yml`：新版本進到 `master` 時，透過 Trusted Publishing 自動發佈到 RubyGems。
- CLAUDE.md 加入發版規則。

### Changed

- 移除每個 gemfile 各自的舊 lockfile，這些 lockfile 會讓 CI 在較舊的 Ruby 上失敗。

## [1.2.0] - 2026-01-08

### Added

- 新增 Ruby 3.2 與 3.3 的測試 gemfile（`ruby_3.2_rails_7.0`、`ruby_3.2_rails_7.1`、`ruby_3.3_rails_7.1`）與 CI job。

### Changed

- gemspec 的 `required_ruby_version` 上限由 `< 3.2.0` 提高到 `< 3.4.0`。

## [1.1.2] - 2026-01-07

### Changed

- 更新各 gemfile 的 lockfile。

## [1.1.1] - 2026-01-07

### Added

- 多版本 Ruby / Rails 測試環境：每個版本各自的 gemfile、GitHub Actions 矩陣、`bin/test_all`、`bin/check_dependencies` 與 `TESTING.md`。

### Fixed

- 測試不再依賴寫死的 macOS 路徑。

## [1.1.0] - 2023-02-02

### Changed

- 修正並微調 XLSX exporter（`ExportTo::Exporter::Xlsx`）。

## [1.0.0] - 2023-02-02

### Changed

- 內部改寫：匯出邏輯移到 `ExportTo::Exporter::Csv` / `Xls` / `Xlsx`；`ExportTo::Base` 提供 `to_csv`、`to_xlsx` 與 `to_xls`。
- `activesupport` 限制為 `>= 6, < 7`；開發相依套件放寬為 `bundler >= 2.0`、`rake >= 13`。

## [0.1.2] - 2019-06-19

### Changed

- CSV 輸出現在會強制幫每個欄位加上引號。

## [0.1.1] - 2018-12-05

### Fixed

- 修正匯出時出現 "File exists" 的 bug。

## [0.1.0] - 2018-10-21

### Added

- 首次發佈：`ExportTo::Base` DSL（`set`、`joins`、`presenter`、`each_with`）、帶有列計數器的 presenter、空的 join relation 處理，以及 `to_xlsx`。

[Unreleased]: https://github.com/superlanding/export_to/compare/v1.2.1...HEAD
[1.2.1]: https://github.com/superlanding/export_to/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/superlanding/export_to/compare/v1.1.2...v1.2.0
[1.1.2]: https://github.com/superlanding/export_to/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/superlanding/export_to/releases/tag/v1.1.1
[1.1.0]: https://github.com/superlanding/export_to/commit/48957da
[1.0.0]: https://github.com/superlanding/export_to/commit/8d7f937
[0.1.2]: https://github.com/superlanding/export_to/commit/d276482
[0.1.1]: https://github.com/superlanding/export_to/commit/12dd5c1
[0.1.0]: https://github.com/superlanding/export_to/commit/d605bf9
