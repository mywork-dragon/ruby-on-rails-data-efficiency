require 'test_helper'
require 'mocks/httparty_mock'

class EpfApplicationLoaderTest < ActiveSupport::TestCase

  test 'parse file' do
    loader = EpfApplicationLoader.new(
      source: :epf_weekly
    )
    response = loader.parse_file('test/data/application.gz')
    ios_app = IosApp.find_by_app_identifier(903351912)
    assert ios_app
    assert_equal DateTime.new(2014, 07, 31), ios_app.released
    assert_equal 'epf_weekly', ios_app.source
    assert_equal 0, response[:existing_apps_count]
    assert_equal 1, response[:new_apps_count]
  end

  test 'get url for date' do
    loader = EpfApplicationLoader.new(token: 'junk')
    mock = HttpartyMock.new
    # yuck
    mock.register(
      {
        url: "https://feeds.mightysignal.com/v1/internal/epf/incremental/application/latest/application.gz",
        options: {
          headers: { 'JWT' => 'junk' },
          follow_redirects: false
        }
      },
      {
        body: nil,
        code: 307,
        headers: {'location' => 'someredirect.com'}
      }
    )
    loader.http_client = mock
    url = loader.get_url_for_date('latest', true)
    assert_equal 'someredirect.com', url
  end

  test 'parse file handles existing' do
      ios_app = IosApp.create!(app_identifier: 903351912)
      previous = IosApp.count
      response = EpfApplicationLoader.new.parse_file('test/data/application.gz')
      assert_equal previous, IosApp.count
      assert_equal 1, response[:existing_apps_count]
      assert_equal 0, response[:new_apps_count]
  end
end
