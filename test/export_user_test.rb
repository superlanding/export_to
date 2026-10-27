require "test_helper"

describe "ExportUser" do

  class ExportUser < ExportTo::Base

    amount_proc = -> ( value ) { value + 100 }

    set '名字', :full_name, width: 50
    set '手機', :mobile, width: 100, format: { bold: true }
    set '地址', :address
    set '金額', :amount, width: 40, &amount_proc

    joins :wallets

    each_with do |presenter|

    end

    presenter do
      def full_name
        "#{first_name} #{last_name}"
      end

      def amount
        relation? ? relation.amount : 0
      end
    end
  end

  User = Struct.new(:first_name, :last_name, :mobile, :address, :wallets)
  Wallet = Struct.new(:amount)

  should ".presenter_klass == ExportUser::Presenter" do
    assert ExportUser::Presenter, ExportUser.presenter_klass
  end

  before do
    @users = [
      User.new('Eddie', 'Li', '+886977777777', 'Kaohsiung city', []),
      User.new('Vegeta', 'Lu', '+886938234134', 'Taipei city', [ Wallet.new(1000), Wallet.new(2000) ])
    ]
    @export = ExportUser.new(@users)
  end

  def capture_stderr
    original = $stderr
    $stderr = StringIO.new
    yield
    $stderr.string
  ensure
    $stderr = original
  end

  def reset_to_xls_warning(value)
    ExportTo::Base.to_xls_warned = value if ExportTo::Base.respond_to?(:to_xls_warned=)
  end

  XLSX_MAGIC = "PK\x03\x04".b          # an .xlsx file is a zip archive
  XLS_MAGIC  = "\xD0\xCF\x11\xE0\xA1\xB1\x1A\xE1".b # a legacy .xls file is an OLE2 compound file

  describe "#to_xlsx" do
    should "will not throw exception" do
      assert @export.to_xlsx.present?
    end

    should "return xlsx (zip) data" do
      assert_equal XLSX_MAGIC, @export.to_xlsx.b[0, 4]
    end
  end

  describe "#to_xls" do
    before { reset_to_xls_warning(nil) }
    after  { reset_to_xls_warning(true) }

    should "will not throw exception" do
      capture_stderr { assert @export.to_xls.present? }
    end

    # Compatibility: since 1.0.0 `to_xls` returns the same xlsx data as `to_xlsx`.
    # Callers may depend on it, so this is intentionally kept (and deprecated).
    should "still return xlsx (zip) data, not a legacy xls file" do
      capture_stderr do
        assert_equal XLSX_MAGIC, @export.to_xls.b[0, 4]
      end
    end

    should "warn about the deprecation only once" do
      first = capture_stderr { @export.to_xls }
      second = capture_stderr { @export.to_xls }
      assert_match(/DEPRECATION.*to_xls.*to_xlsx/, first)
      assert_equal "", second
    end

    should "not warn when using #to_xlsx" do
      assert_equal "", capture_stderr { @export.to_xlsx }
    end
  end

  describe "ExportTo::Exporter::Xls" do
    should "build a real legacy xls file" do
      data = ExportTo::Exporter::Xls.new(@export).to_xls
      assert_equal XLS_MAGIC, data.b[0, 8]
    end
  end

  describe "#each" do
    should "return all rows (table head first) as an array" do
      assert_equal [
        ['名字', '手機', '地址', '金額'],
        ['Eddie Li', '+886977777777', 'Kaohsiung city', 100],
        ['Vegeta Lu', '+886938234134', 'Taipei city', 1100],
        ['Vegeta Lu', '+886938234134', 'Taipei city', 2100]
      ], @export.each
    end

    should "match the rows of #to_csv" do
      assert_equal CSV.parse(@export.to_csv), @export.each.map { |row| row.map(&:to_s) }
    end

    should "yield each row to a block and return self" do
      rows = []
      assert_same @export, @export.each { |row| rows << row }
      assert_equal @export.each, rows
    end

    should "work with Enumerable methods" do
      assert_equal ['名字', 'Eddie Li', 'Vegeta Lu', 'Vegeta Lu'], @export.map(&:first)
    end
  end

  describe "#to_csv" do
    before do
      @csv_content = @export.to_csv
      @rows = CSV.parse(@csv_content)
    end

    should "#count = 4 (include table head)" do
      assert_equal 4, @rows.count
    end

    context "content: " do
      should "[0, 0] = '名字'" do
        assert_equal '名字', @rows[0][0]
      end

      should "[0, 1] = '手機'" do
        assert_equal '手機', @rows[0][1]
      end

      should "[0, 2] = '地址'" do
        assert_equal '地址', @rows[0][2]
      end

      should "[0, 3] = '金額'" do
        assert_equal '金額', @rows[0][3]
      end

      should "[1, 0] = 'Eddie Li'" do
        assert_equal 'Eddie Li', @rows[1][0]
      end

      should "[1, 1] = '+886977777777'" do
        assert_equal '+886977777777', @rows[1][1]
      end

      should "[1, 2] = 'Kaohsiung city'" do
        assert_equal 'Kaohsiung city', @rows[1][2]
      end

      should "[1, 3] = '0'" do
        assert_equal '100', @rows[1][3]
      end

      should "[2, 0] = 'Vegeta Lu'" do
        assert_equal 'Vegeta Lu', @rows[2][0]
      end

      should "[2, 1] = '+886938234134'" do
        assert_equal '+886938234134', @rows[2][1]
      end

      should "[2, 2] = 'Taipei city'" do
        assert_equal 'Taipei city', @rows[2][2]
      end

      should "[2, 3] = '1100'" do
        assert_equal '1100', @rows[2][3]
      end

      should "[3, 3] = '2100'" do
        assert_equal '2100', @rows[3][3]
      end
    end
  end
end
