# ExportTo

[![Gem Version](https://badge.fury.io/rb/export_to.svg)](https://rubygems.org/gems/export_to)
[![CI](https://github.com/superlanding/export_to/actions/workflows/ci.yml/badge.svg)](https://github.com/superlanding/export_to/actions/workflows/ci.yml)

Export a collection of records (ActiveRecord relations, arrays of Structs, anything that responds to `each`) to **CSV**, **XLSX** or **XLS** with a small declarative DSL.

You describe the columns once (title, source attribute, width, format, value transform) in an `ExportTo::Base` subclass, optionally add a presenter for computed columns and a `joins` relation that expands one record into several rows, then call `to_csv` / `to_xlsx` / `to_xls`.

## Requirements

| Ruby | Rails / ActiveSupport tested in CI |
|------|------------------------------------|
| 2.7  | 6.1 |
| 3.0  | 6.1, 7.0 |
| 3.1  | 6.1, 7.0, 7.1 |
| 3.2  | 7.0, 7.1 |
| 3.3  | 7.1, 8.0, 8.1 |
| 3.4  | 8.0, 8.1 |

The gemspec requires Ruby `>= 2.7.0` and `activesupport >= 6.0, < 8.2`. The source of truth is [`.github/workflows/ci.yml`](.github/workflows/ci.yml).

Runtime dependencies: `fast_excel` (XLSX), `spreadsheet` (XLS), `csv`, `iconv`, `activesupport`.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "export_to"
```

And then execute:

```bash
bundle install
```

Or install it yourself with `gem install export_to`.

## Usage

### 1. Define an exporter

```ruby
class UserExport < ExportTo::Base
  # set <header title>, <key>, <column options>, &optional_transform
  set "Name",   :full_name, width: 30
  set "Mobile", :mobile,    width: 20, format: { bold: true }
  set "Amount", :amount,    width: 12 do |value|
    value + 100                    # the block receives the cell value and returns the final one
  end
  set "Source", "web"              # a String key is written as a fixed value in every row

  excel worksheet: "Users", height: 24   # optional XLSX settings (worksheet name, row height)

  presenter do                     # optional: computed columns
    def full_name
      "#{first_name} #{last_name}" # unknown methods are delegated to the record
    end

    def amount
      relation? ? relation.amount : 0
    end
  end

  joins :wallets                   # optional: one row per record in record.wallets
end
```

- **`set(title, key, options = {}, &block)`**: one column per call, in order.
  - `key` as a **Symbol** is read from the presenter (which delegates to the record); `nil` becomes `""`.
  - `key` as a **String** is used literally.
  - XLSX `options`: `width:` (column width) and `format:` (a `FastExcel` format hash, e.g. `{ bold: true }`).
  - The optional block post-processes the cell value.
- **`excel(worksheet: "Name", height: 20)`**: worksheet name (default `"Default"`) and data row height (default `20`). The header row is bold, centered and has a background color.
- **`presenter { ... }`**: defines `YourExport::Presenter` (a subclass of the parent exporter's presenter). Inside it you can use `model`, `relation`, `relation?`, `x` (record index) and `y` (index inside the `joins` relation).
- **`joins(:relation_name)`**: when `record.relation_name` is present, every element becomes its own row and `relation` is that element; the presenter first looks for a method on `relation`, then on `model`. Records with an empty relation produce a single row (`relation?` is `false`).
- **`each_with { |presenter| ... }`**: a hook called with each row's presenter before the columns are read.
- **`self.each_method = :find_in_batches`**: iterate with `records.find_in_batches` instead of `records.each`, for large ActiveRecord relations.

### 2. Export

```ruby
users  = User.includes(:wallets).where(active: true)   # or any enumerable
export = UserExport.new(users)

export.to_csv    # => String, every field quoted ("Name","Mobile",...)
export.to_xlsx   # => binary String of an .xlsx file
```

Example CSV output for two users (the second has two wallets):

```
"Name","Mobile","Amount","Source"
"Eddie Li","+8869","100","web"
"Vegeta Lu","+8868","1100","web"
"Vegeta Lu","+8868","2100","web"
```

Serving it from a Rails controller:

```ruby
def export
  send_data UserExport.new(User.all).to_xlsx,
            filename: "users.xlsx",
            type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
end
```

### Known limitations

These describe the current behavior of the code:

- `ExportTo::Base#to_xls` currently delegates to the **XLSX** exporter, so it returns xlsx data. For a real legacy `.xls` file use `ExportTo::Exporter::Xls.new(export).to_xls`.
- `ExportTo::Base#each` calls an undefined `rows!` and raises `NoMethodError`. Iterate with `each!` (yields `columns, record, index`, with the header row first) or use one of the `to_*` methods.
- `width:` / `format:` and `excel` options only affect XLSX output.
- Subclasses share the column definitions arrays of their parent class (`class_attribute`), so do not call `set` on a subclass of an exporter that is used on its own.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then run the tests:

```bash
bundle exec rake test        # also: rake t / rake (default)
bin/console                  # interactive prompt
```

Each Ruby / Rails combination has its own gemfile in `gemfiles/` (CI sets `BUNDLE_GEMFILE` to it):

```bash
BUNDLE_GEMFILE=$PWD/gemfiles/ruby_3.4_rails_8.1.gemfile bundle install
BUNDLE_GEMFILE=$PWD/gemfiles/ruby_3.4_rails_8.1.gemfile bundle exec rake test
```

`bin/test_all` runs every supported Ruby (needs rbenv or rvm) and `bin/check_dependencies` checks dependency compatibility; see [TESTING.md](TESTING.md) for details (its version lists can lag behind CI).

## Releasing

Releases are automated with RubyGems [Trusted Publishing](https://guides.rubygems.org/trusted-publishing/) (no API key is stored in the repo):

1. In your PR, bump `ExportTo::VERSION` in `lib/export_to/version.rb` ([Semantic Versioning](https://semver.org/): patch for fixes, minor for compatible features, major for breaking changes).
2. Add a matching `## [x.y.z] - YYYY-MM-DD` section to `CHANGELOG.md`.
3. A human reviews and merges the PR into `master` (AI accounts can only open PRs).
4. [`.github/workflows/publish.yml`](.github/workflows/publish.yml) runs on `master`: if the gemspec version is not on rubygems.org yet it runs `rake release` (builds the gem, tags `vX.Y.Z`, publishes). A merge without a version bump publishes nothing.

Docs/CI-only PRs do not need a version bump. See [CLAUDE.md](CLAUDE.md): every PR must also update `README.md` (when behavior or usage changes) and add an entry to `CHANGELOG.md`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/superlanding/export_to.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
