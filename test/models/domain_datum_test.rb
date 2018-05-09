require 'test_helper'

class ClearbitContactTest < ActiveSupport::TestCase
  test "That populating geo data clears all existing geo data" do
    company_data = {
      :geo => {
        :city => 'San Francisco',
        :state => 'California',
        :countryCode => 'US'
      }
    }
    company_data2 = {
      :geo => {
        :state => 'New York',
        :countryCode => 'US'
      }
    }
    dd = DomainDatum.create!(domain: "mightysignal.com")
    dd.populate(company_data)
    assert_equal 'San Francisco', dd.city
    assert_equal 'California', dd.state
    assert_equal 'US', dd.country_code

    dd.populate(company_data2)
    assert_equal nil, dd.city
    assert_equal 'US', dd.country_code
    assert_equal 'New York', dd.state


  end
end
