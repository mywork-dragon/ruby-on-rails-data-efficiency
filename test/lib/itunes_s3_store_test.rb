require 'test_helper'
require 'mocks/mighty_aws_s3_mock'

class ItunesS3StoreTest < ActiveSupport::TestCase

  def setup
    @s3 = MightyAwsS3Mock.new
    @fb_app_id = 123
  end

  test 'it validates for known types' do
    @lib = ItunesS3Store.new
    @lib.s3_client = @s3
    @lib.store!(123, 'us', :html, 'hello')
    @lib.store!(123, 'us', :html, '{"sup": "hi"}')
    assert_raises(ItunesS3Store::InvalidType) do
      @lib.store!(123, 'us', :csv, '123,456,789')
    end
  end

  test 'stores html data in known keypath' do
    data_html = 'sup'
    timestamp = Time.now

    @lib = ItunesS3Store.new
    @lib.s3_client = @s3

    Time.stub :now, timestamp do
      @lib.store!(123, 'us', :html, data_html)
    end
    assert_equal data_html, @s3.data
    assert_equal File.join(123.to_s, 'us', 'html', "#{timestamp.utc.iso8601}.html.gz"), @s3.key_stored_to
  end

  test 'stores json data in known keypath' do
    data_json = '{"sup": "hi"}'
    timestamp = Time.now

    @lib = ItunesS3Store.new
    @lib.s3_client = @s3

    Time.stub :now, timestamp do
      @lib.store!(123, 'us', :json, data_json)
    end
    assert_equal data_json, @s3.data
    assert_equal File.join(123.to_s, 'us', 'json', "#{timestamp.utc.iso8601}.json.gz"), @s3.key_stored_to
  end

  test 'raises if not valid json' do
    @lib = ItunesS3Store.new
    @lib.s3_client = @s3

    assert_raises(JSON::ParserError) do
      @lib.store!(123, 'us', :json, '{:blah=>"value"}')
    end
  end
end
