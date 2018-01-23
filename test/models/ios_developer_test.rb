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
    ENV['HOT_STORE_REDIS_URL'] = ENV['VARYS_REDIS_URL']
    ENV['HOT_STORE_REDIS_PORT'] = ENV['VARYS_REDIS_PORT']
    DomainDataHotStore.new.write({'domain' => 'mightysignal.com', 'publishers' => [{'publisher_id' => @developer.id, 'platform' => 'ios'}]})
    res = IosDeveloper.find_by_domain('mightysignal.com')
    assert_equal 1, res.count
    assert_equal @developer.identifier, res.first.identifier
  end

end
