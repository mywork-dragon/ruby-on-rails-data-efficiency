require 'test_helper'
require 'minitest/mock'

class GoogleTranslateApiTest < Minitest::Test

  def setup
    @bad_response = MiniTest::Mock.new
    @bad_response.expect(:code, 400)

    @good_response = MiniTest::Mock.new
    @good_response.expect(:code, 200)

    example_response = '{
        "data": {
              "translations": [
                      {
                                "translatedText": "September",
                                        "detectedSourceLanguage": "pt"
                      }
                          ]
                }
    }'

    @good_response.expect(:body, example_response)
  end

  def test_raises_exception_on_bad_response
    GoogleTranslateApi.stub :get, @bad_response do
      assert_raises(GoogleTranslateApi::FailedRequest) do
        GoogleTranslateApi.translate('hello')
      end
    end

    @bad_response.verify
  end

  def test_returns_translated_text
    GoogleTranslateApi.stub :get, @good_response do
      assert_equal 'September', GoogleTranslateApi.translate('setembro')
    end

    @good_response.verify
  end
end
