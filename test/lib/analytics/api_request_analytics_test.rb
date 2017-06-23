require 'test_helper'
require 'mocks/mock_request'

class ApiRequestAnalyticsTest < ActiveSupport::TestCase
  def setup
    account = Account.create!(name: 'Osman')
    @token = ApiToken.create!(token: 'asdf', rate_limit:2000, rate_window: :hourly, account_id: account.id)
    @request = MockRequest.new
    @analytics = ApiRequestAnalytics.new(@request, @token)
    @analytics.throttler = MockThrottler.new
  end

  test 'add_user_data' do
    @analytics.add_user_data
    assert_equal @token.account.name, @analytics.event_data[:user_id]
    assert_equal @token.id, @analytics.event_data[:event_properties][:token_id]
  end

  test 'add request data' do
    @analytics.add_request_data
    assert_equal @request.uuid, @analytics.event_data[:event_properties][:request_id]
    assert_equal @request.request_method, @analytics.event_data[:event_properties][:method]
    assert_equal @request.original_url, @analytics.event_data[:event_properties][:url]
    assert_equal 5, @analytics.event_data[:event_properties][:window_request_count]
    key = @request.query_parameters.keys.first
    assert_equal @request.query_parameters[key], @analytics.event_data[:event_properties]["param_#{key}"]
  end

  class MockThrottler
    def status
      {
        current: 5,
        limit: 10,
        period: 3600
      }
    end
  end
end

