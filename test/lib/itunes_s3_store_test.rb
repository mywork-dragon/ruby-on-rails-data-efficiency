require 'test_helper'
require 'mocks/mighty_aws_s3_mock'

class ItunesS3StoreTest < ActiveSupport::TestCase

  def setup
    @s3 = MightyAwsS3Mock.new
    @fb_app_id = 123
  end

  test 'it validates for known types' do
    ItunesS3Store.new(123, 'us', data_str: 'hello', data_type: :html)
    ItunesS3Store.new(123, 'us', data_str: '{"sup": "hi"}', data_type: :html)
    assert_raises(ItunesS3Store::InvalidType) do
      ItunesS3Store.new(123, 'us', data_str: '123,456,789', data_type: :csv)
    end
  end

  test 'stores html data in known keypath' do
    data_html = 'sup'
    timestamp = Time.now

    @lib = ItunesS3Store.new(123, 'us', data_str: data_html, data_type: :html)
    @lib.s3_client = @s3

    Time.stub :now, timestamp do
      @lib.store!
    end
    assert_equal data_html, @s3.data
    assert_equal File.join(123.to_s, 'us', 'html', "#{timestamp.utc.iso8601}.html.gz"), @s3.key_stored_to
  end

  test 'stores json data in known keypath' do
    data_json = '{"sup": "hi"}'
    timestamp = Time.now

    @lib = ItunesS3Store.new(123, 'us', data_str: data_json, data_type: :json)
    @lib.s3_client = @s3

    Time.stub :now, timestamp do
      @lib.store!
    end
    assert_equal data_json, @s3.data
    assert_equal File.join(123.to_s, 'us', 'json', "#{timestamp.utc.iso8601}.json.gz"), @s3.key_stored_to
  end
end
