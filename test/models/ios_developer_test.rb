require 'test_helper'

class IosDeveloperTest < ActiveSupport::TestCase
  def setup
    @developer = IosDeveloper.create!(
      name: 'MS development Co',
      identifier: 1234
    )
    @website = Website.create!(
      url: 'https://mightysignal.com',
      match_string: 'mightysignal.com',
      domain: 'mightysignal.com'
    )
  end

  test 'api json format' do
    res = @developer.api_json
    assert_instance_of String, res[:name]
    assert_equal :ios, res[:platform]
    assert_instance_of Integer, res[:app_store_id]
    assert_instance_of Array, res[:websites]
    assert_instance_of Array, res[:details]
  end

  test 'short api json format excludes websites and details' do
    res = @developer.api_json(short_form: true)
    assert_instance_of String, res[:name]
    assert_equal :ios, res[:platform]
    assert_instance_of Integer, res[:app_store_id]
    assert_nil res[:websites]
    assert_nil res[:details]
  end

  test 'finds developer by domain' do
    x = IosDevelopersWebsite.create!(
      ios_developer_id: @developer.id,
      website_id: @website.id,
      is_valid: true
    )
    x.update(is_valid: true) # override callback on model
    res = IosDeveloper.find_by_domain('mightysignal.com')
    assert_equal 1, res.count
    assert_equal @developer.identifier, res.first.identifier
  end

  test 'finds developer by domain ignoring flagged associations' do
    x = IosDevelopersWebsite.create!(
      ios_developer_id: @developer.id,
      website_id: @website.id,
      is_valid: false
    )
    x.update(is_valid: false) # override callback on model
    res = IosDeveloper.find_by_domain('mightysignal.com')
    assert_equal 0, res.count
  end
end
