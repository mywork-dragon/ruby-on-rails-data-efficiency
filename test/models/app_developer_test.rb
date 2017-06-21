require 'test_helper'

class AppDeveloperTest < ActiveSupport::TestCase
  def setup
    @ios_developer = IosDeveloper.create!(
      name: 'MS development Co',
      identifier: 1234
    )
    @android_developer = AndroidDeveloper.create!(
      name: 'MS development Co',
      identifier: 'android'
    )
    @app_developer = AppDeveloper.create!(name: 'something')
    AppDevelopersDeveloper.create!(app_developer: @app_developer, developer: @ios_developer)
    AppDevelopersDeveloper.create!(app_developer: @app_developer, developer: @android_developer)
  end

  test 'as_json format is as expected' do
    res = @app_developer.as_json
    assert_equal @app_developer.name, res[:name]
    assert_equal 1, res[:ios_publishers].count
    assert_equal 1, res[:android_publishers].count
    assert_nil res[:ios_publishers].first[:details] # test short form
    assert_nil res[:android_publishers].first[:details] # test short form
    assert_equal 4, res.keys.count
  end
end
