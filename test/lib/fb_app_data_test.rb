require 'test_helper'
require 'mocks/mighty_aws_s3_mock'

class FbAppDataTest < ActiveSupport::TestCase

  def setup
    @s3 = MightyAwsS3Mock.new
    @fb_app_id = 123
    @lib = FbAppData.new(@fb_app_id)
    @lib.s3_client = @s3
  end

  test 'stores historical data to s3' do
    data = { "name" => "sup", "monthly_active_users" => 1_000_000}
    timestamp = Time.at(0)

    Time.stub :now, timestamp do
      @lib.store_historical(data)
    end

    assert_equal data.to_json, @s3.data
    assert_equal "historical/#{@fb_app_id}/#{timestamp.utc.iso8601}.json.gz", @s3.key_stored_to
  end

  test 'stores latest data to s3' do
    data = { "name" => "sup", "monthly_active_users" => 1_000_000}

    @lib.store_latest(data)
    assert_equal data.to_json, @s3.data
    assert_equal "latest/#{@fb_app_id}.json.gz", @s3.key_stored_to
  end

  test 'returns Unavailable when requesting key that does not exist' do
    assert_equal FbAppData::Unavailable, @lib.latest
  end
end
