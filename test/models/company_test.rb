require 'test_helper'

class CompanyTest < ActiveSupport::TestCase

  
  def setup
      @company = Company.new(name: "bizible.com", website: "http://www.bizible.com", status: :active)
  end

    test "should be valid" do
      assert !@company.valid?
    end
end