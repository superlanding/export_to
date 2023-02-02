require "test_helper"

describe "ExportUser" do

  class ExportUser < ExportTo::Base

    amount_proc = -> ( value ) { value + 100 }

    set '名字', :full_name, format: { width: 50 }
    set '手機', :mobile, format: { width: 100, bold: true }
    set '地址', :address
    set '金額', :amount, format: { width: 40 }, &amount_proc

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

  describe "#to_xlsx" do
    should "will not throw exception" do
      File.open('/Users/adz/Documents/xxxx.xlsx', 'wb') {|f| f.write(@export.to_xlsx) }
      assert @export.to_xlsx.present?
    end
  end

  describe "#to_xls" do
    should "will not throw exception" do
      assert @export.to_xls.present?
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
