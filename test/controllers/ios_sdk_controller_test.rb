require 'test_helper'
require 'action_controller'

class IosSdkControllerTest < ActionController::TestCase

  def test_the_truth
    assert_equal true, true
  end

  def test_validation_success
    @controller.stub :authenticate_admin_account, nil do
      assert_equal 200, post(:validate, ios_sdk: {name: 'sup', website: 'http://google.com', classes: ['ABC']}).status
    end
  end

  def test_invalid_cases
    @controller.stub :authenticate_admin_account, nil do
      assert_equal 400, post(:validate, ios_sdk: {website: 'http://google.com', classes: ['ABC']}).status
      assert_equal 400, post(:validate, ios_sdk: {name: 'sup', classes: ['ABC']}).status
      assert_equal 400, post(:validate, ios_sdk: {name: 'sup', website: 'http://google.com'}).status
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

  def test_athena_query
    sdk = IosSdk.create!(name: 'sup', kind: :native)
    IosSdkSourceData.create!(name: 'my_custom_header', ios_sdk_id: sdk.id)
    @controller.stub :authenticate_admin_account, nil do
      res = get(:athena_query, {ios_sdk_ids: "#{sdk.id}"})
      assert_equal 200, res.status
      query = JSON.parse(res.body)['query']
      assert_not_nil query
      assert /select DISTINCT\(id\)/i.match(query)
      assert /my_custom_header/.match(query)
    end
  end
end
