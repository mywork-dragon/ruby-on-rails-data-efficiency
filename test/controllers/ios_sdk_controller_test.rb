require 'test_helper'
require 'action_controller'

class IosSdkControllerTest < ActionController::TestCase

  def test_validation_success
    @controller.stub :authenticate_admin_account, nil do
      assert_equal 200, post(:validate, ios_sdk: {name: 'sup', website: 'http://google.com', classes: ['ABC']}).status
    end
  end

  def test_invalid_cases
    collision_header = 'collision'
    IosSdkSourceData.create!(name: collision_header)
    @controller.stub :authenticate_admin_account, nil do
      assert_equal 400, post(:validate, ios_sdk: {website: 'http://google.com', classes: ['ABC']}).status
      assert_equal 400, post(:validate, ios_sdk: {name: 'sup', classes: ['ABC']}).status
      assert_equal 400, post(:validate, ios_sdk: {name: 'sup', website: 'http://google.com'}).status
      assert_equal 400, post(:validate, ios_sdk: {name: 'sup', website: 'http://google.com', classes: [collision_header]}).status
    end
  end

  def test_sdk_creation
    sdk = {
      name: 'sdk',
      website: 'https://sdk.com',
      classes: ['sdk1', 'sdk2']
    }
    @controller.stub :authenticate_admin_account, nil do
      assert_equal 201, post(:create, ios_sdk: sdk).status
      created = IosSdk.find_by_name(sdk[:name])
      assert created
      assert sdk[:website], created.website
      assert_equal 2, created.ios_sdk_source_datas.count
    end
  end
end
