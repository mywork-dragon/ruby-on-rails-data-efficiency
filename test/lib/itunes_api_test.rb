require 'test_helper'

class ItunesApiTest < ActiveSupport::TestCase
  def setup
    @good_response = MiniTest::Mock.new
    @good_response.expect(:body, open(File.join(Rails.root, 'test', 'data', 'itunes_uber_us.html')).read)
  end

  test 'hits the app store with the correct url' do

    url_checker = lambda { |url| 
      assert_equal '/us/app/id368677368', url
      @good_response
    }

    ItunesApi.stub(:get, url_checker) do
      ItunesApi.web_scrape(368677368)
    end
  end
end
