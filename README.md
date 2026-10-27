# ExportTo

[![Gem Version](https://badge.fury.io/rb/export_to.svg)](https://rubygems.org/gems/export_to)
[![CI](https://github.com/superlanding/export_to/actions/workflows/ci.yml/badge.svg)](https://github.com/superlanding/export_to/actions/workflows/ci.yml)

用一套簡單的宣告式 DSL，把一批資料（ActiveRecord relation、Struct 陣列，或任何有 `each` 的物件）匯出成 **CSV** 或 **XLSX**（透過較底層的 exporter，也能匯出舊版 **XLS**）。

你只要在 `ExportTo::Base` 的子類別裡宣告一次欄位（標題、來源屬性、寬度、格式、值的轉換），需要計算欄位時可以加上 presenter，也可以加上 `joins` relation 把一筆資料展開成多列，最後呼叫 `to_csv` / `to_xlsx` 即可。

## 環境需求

| Ruby | CI 測試的 Rails / ActiveSupport 版本 |
|------|------------------------------------|
| 2.7  | 6.1 |
| 3.0  | 6.1, 7.0 |
| 3.1  | 6.1, 7.0, 7.1 |
| 3.2  | 7.0, 7.1 |
| 3.3  | 7.1, 8.0, 8.1 |
| 3.4  | 8.0, 8.1 |

gemspec 要求 Ruby `>= 2.7.0` 與 `activesupport >= 6.0, < 8.2`。實際支援範圍以 [`.github/workflows/ci.yml`](.github/workflows/ci.yml) 為準。

Runtime 相依套件：`fast_excel`（XLSX）、`spreadsheet`（XLS）、`csv`、`iconv`、`activesupport`。

## 安裝

在應用程式的 Gemfile 加入這一行：

```ruby
gem "export_to"
```

然後執行：

```bash
bundle install
```

或自行執行 `gem install export_to` 安裝。

## 使用方式

### 1. 定義 exporter

```ruby
class UserExport < ExportTo::Base
  # set <標題>, <key>, <欄位選項>, &可選的轉換 block
  set "Name",   :full_name, width: 30
  set "Mobile", :mobile,    width: 20, format: { bold: true }
  set "Amount", :amount,    width: 12 do |value|
    value + 100                    # block 會收到儲存格的值，並回傳最終要輸出的值
  end
  set "Source", "web"              # key 為 String 時，每一列都會寫入這個固定值

  excel worksheet: "Users", height: 24   # 可選的 XLSX 設定（工作表名稱、列高）

  presenter do                     # 可選：計算欄位
    def full_name
      "#{first_name} #{last_name}" # 找不到的方法會委派給該筆 record
    end

    def amount
      relation? ? relation.amount : 0
    end
  end

  joins :wallets                   # 可選：record.wallets 裡每一筆各佔一列
end
```

- **`set(title, key, options = {}, &block)`**：每次呼叫新增一個欄位，依呼叫順序排列。
  - `key` 為 **Symbol** 時，會從 presenter 讀取（presenter 會委派給 record）；`nil` 會變成 `""`。
  - `key` 為 **String** 時，直接當作固定內容使用。
  - XLSX 專用的 `options`：`width:`（欄寬）與 `format:`（`FastExcel` 的 format hash，例如 `{ bold: true }`）。
  - 可選的 block 用來後處理儲存格的值。
- **`excel(worksheet: "Name", height: 20)`**：工作表名稱（預設 `"Default"`）與資料列的列高（預設 `20`）。標題列為粗體、置中並帶有背景色。
- **`presenter { ... }`**：定義 `YourExport::Presenter`（是上層 exporter 的 presenter 的子類別）。在裡面可以使用 `model`、`relation`、`relation?`、`x`（record 的索引）與 `y`（`joins` relation 內的索引）。
- **`joins(:relation_name)`**：當 `record.relation_name` 有資料時，每個元素各自成為一列，且 `relation` 就是該元素；presenter 會先找 `relation` 上的方法，找不到再找 `model`。relation 為空的 record 會產生單獨一列（此時 `relation?` 為 `false`）。
- **`each_with { |presenter| ... }`**：hook，會在讀取各欄位之前，以每一列的 presenter 呼叫一次。
- **`self.each_method = :find_in_batches`**：改用 `records.find_in_batches` 而不是 `records.each` 來迭代，適合很大的 ActiveRecord relation。

### 2. 匯出

```ruby
users  = User.includes(:wallets).where(active: true)   # 或任何可列舉的物件
export = UserExport.new(users)

export.to_csv    # => String，每個欄位都有加引號（"Name","Mobile",...）
export.to_xlsx   # => .xlsx 檔案的二進位 String
export.each      # => 所有列組成的 Array，第一列是標題列：[["Name", "Mobile", ...], ["Eddie Li", ...], ...]
export.each { |columns| ... }   # 逐列 yield（第一列是標題列），並回傳 exporter 本身；Enumerable 方法也能用
```

兩位使用者的 CSV 輸出範例（第二位有兩個 wallet）：

```
"Name","Mobile","Amount","Source"
"Eddie Li","+8869","100","web"
"Vegeta Lu","+8868","1100","web"
"Vegeta Lu","+8868","2100","web"
```

在 Rails controller 裡提供下載：

```ruby
def export
  send_data UserExport.new(User.all).to_xlsx,
            filename: "users.xlsx",
            type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
end
```

### 已知限制

以下是目前程式碼的實際行為：

- `ExportTo::Base#to_xls` **已棄用，而且名稱有誤導性**：自 1.0.0 起它回傳的是與 `#to_xlsx` 相同的 **XLSX** 資料（不是舊版 `.xls` 檔）。保留這個行為是為了不讓既有呼叫端壞掉；呼叫時會印出一次性的 `[DEPRECATION]` 警告。請改用 `#to_xlsx`。若需要真正的舊版 `.xls` 檔，請用 `ExportTo::Exporter::Xls.new(export).to_xls`（不會套用任何樣式選項）。
- `width:` / `format:` 與 `excel` 選項只對 XLSX 輸出有效。
- 子類別會共用上層 class 的欄位定義陣列（`class_attribute`），所以如果某個 exporter 本身也會單獨使用，就不要在它的子類別裡呼叫 `set`。

## 開發

clone 下來之後，先執行 `bin/setup` 安裝相依套件，接著跑測試：

```bash
bundle exec rake test        # 也可以用 rake t / rake（預設 task）
bin/console                  # 互動式 console
```

每個 Ruby / Rails 組合在 `gemfiles/` 內都有各自的 gemfile（CI 會把 `BUNDLE_GEMFILE` 指到它）：

```bash
BUNDLE_GEMFILE=$PWD/gemfiles/ruby_3.4_rails_8.1.gemfile bundle install
BUNDLE_GEMFILE=$PWD/gemfiles/ruby_3.4_rails_8.1.gemfile bundle exec rake test
```

`bin/test_all` 會跑過所有支援的 Ruby 版本（需要 rbenv 或 rvm），`bin/check_dependencies` 會檢查相依套件的相容性；詳見 [TESTING.md](TESTING.md)。

## 發版

發版透過 RubyGems [Trusted Publishing](https://guides.rubygems.org/trusted-publishing/) 自動完成（repo 內不存放任何 API key）：

1. 在你的 PR 裡修改 `lib/export_to/version.rb` 的 `ExportTo::VERSION`（遵循 [Semantic Versioning](https://semver.org/lang/zh-TW/)：修 bug 跳 patch、相容的新功能跳 minor、不相容的變更跳 major）。
2. 在 `CHANGELOG.md` 新增對應的 `## [x.y.z] - YYYY-MM-DD` 區塊。
3. 由真人 review 後合併進 `master`（AI 帳號只能開 PR）。
4. [`.github/workflows/publish.yml`](.github/workflows/publish.yml) 會在 `master` 上執行：如果 gemspec 的版本還沒上 rubygems.org，就執行 `rake release`（打包 gem、打 `vX.Y.Z` tag、發佈）。沒有跳版號的合併不會發佈任何東西。

只改文件 / CI 的 PR 不需要跳版號。請見 [CLAUDE.md](CLAUDE.md)：每個 PR 也都必須更新 `README.md`（行為或用法有變時）並在 `CHANGELOG.md` 新增一筆條目。

## 貢獻

歡迎到 GitHub 回報問題與提交 pull request：https://github.com/superlanding/export_to。

## 授權

本 gem 以 [MIT License](https://opensource.org/licenses/MIT) 條款開源。
