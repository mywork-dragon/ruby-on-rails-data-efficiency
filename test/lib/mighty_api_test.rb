require 'test_helper'

class MightyApiTest < Minitest::Test

  def setup
    @bad_response = MiniTest::Mock.new
    @bad_response.expect(:code, 400)
    @bad_response.expect(:code, 400)
    @bad_response.expect(:body, '{"error": "Not Found"}')

    @good_response = MiniTest::Mock.new
    @good_response.expect(:code, 200)

    example_response = '{"id":3,"name":"1PasswordExtension","platform":"ios","website":"https://github.com/AgileBits/onepassword-app-extension","summary":"With just a few lines of code, your app can add 1Password support.","apps_count":921}'

    @good_response.expect(:body, example_response)
  end

  def test_raises_exception_on_bad_response
    MightyApi.stub :get, @bad_response do
      assert_raises(MightyApi::FailedRequest) do
        MightyApi.ios_sdk_info(-1)
      end
    end

    @bad_response.verify
  end

  def test_returns_translated_text
    MightyApi.stub :get, @good_response do
      assert_equal 3, MightyApi.ios_sdk_info(3)['id']
    end

    @good_response.verify
  end
end
