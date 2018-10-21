require "test_helper"

describe "ExportTo::Base" do
  should ".presenter_klass = ExportTo::Base" do
    assert_equal ExportTo::Presenter, ExportTo::Base.presenter_klass
  end
end
