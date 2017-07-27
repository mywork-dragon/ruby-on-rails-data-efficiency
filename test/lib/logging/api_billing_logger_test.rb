require 'test_helper'
require 'mocks/mock_request'

class ApiBillingLoggerTest < ActiveSupport::TestCase
  def setup
    @request = MockRequest.new
    @account = Account.create(name: 'Test')
    @api_token = ApiToken.create!(account_id: @account.id, token: 'asdfasdf')
  end

  test 'build event' do
    logger = ApiBillingLogger.new(@request, @api_token)
    logger.build_event
    assert_equal @request.uuid, logger.event[:request_id]
    assert_equal @request.request_method, logger.event[:request_method]
    assert_equal @request.fullpath, logger.event[:request_fullpath]
    assert_kind_of String, logger.event[:request_timestamp]
    assert_equal @api_token.account_id, logger.event[:account_uuid]
    assert_equal @api_token.account_id, logger.event[:account_uuid]
    assert_equal @account.name, logger.event[:account_name]
  end
end
