require 'test_helper'
require 'action_controller'

class ApiControllerTest < ActionController::TestCase
  
  def setup
    ServiceStatus.create!(:service => :ios_live_scan, :active => true)
    ServiceStatus.create!(:service => :android_live_scan, :active => true)
    ApplicationController.any_instance.stub(:authenticate_request)
    @ios_app = IosApp.create!(app_identifier: 123)
    @android_app = AndroidApp.create!(app_identifier: 'com.mighty.fun')
  end

  test "livescan enabled when admin account and service enabled." do
    ApplicationController.any_instance.stub(:logged_into_admin_account?) { true }

    post(:ios_sdks_exist, {'appId' => @ios_app.id})
    assert JSON.parse(@response.body)['live_scan_enabled']

    post(:android_sdks_exist, {'appId' => @android_app.id})
    assert JSON.parse(@response.body)['live_scan_enabled']
  end

  test "livescan enabled when non admin account but service enabled." do
    ApplicationController.any_instance.stub(:logged_into_admin_account?) { false }

    post(:ios_sdks_exist, {'appId' => @ios_app.id})
    assert JSON.parse(@response.body)['live_scan_enabled']

    post(:android_sdks_exist, {'appId' => @android_app.id})
    assert JSON.parse(@response.body)['live_scan_enabled']
  end

  test "livescan disabled when non admin account and service disabled." do
    ServiceStatus.disable(:ios_live_scan)
    ServiceStatus.disable(:android_live_scan)
    ApplicationController.any_instance.stub(:logged_into_admin_account?) { false }

    post(:ios_sdks_exist, {'appId' => @ios_app.id})
    assert_not JSON.parse(@response.body)['live_scan_enabled']

    post(:android_sdks_exist, {'appId' => @android_app.id})
    assert_not JSON.parse(@response.body)['live_scan_enabled']
  end

  test "test get_android_category_objects returns categories" do
    mock_response =  ["AUTO_AND_VEHICLES", "COMICS", "COMMUNICATION", "DATING", "FAMILY_CREATE", 
                      "FAMILY_EDUCATION", "GAME_CARD", "GAME_SPORTS", "HEALTH_AND_FITNESS", "LIBRARIES_AND_DEMO", "MAPS_AND_NAVIGATION", "SHOPPING", "TOOLS", "TRAVEL_AND_LOCAL", 
                      "BOOKS_AND_REFERENCE", "BUSINESS", "EDUCATION", "FAMILY_PRETEND", "GAME_ARCADE", 
                      "GAME_CASINO", "GAME_CASUAL", "GAME_MUSIC", "GAME_PUZZLE", "GAME_WORD", 
                      "PARENTING", "PERSONALIZATION", "VIDEO_PLAYERS", "WEATHER", "ART_AND_DESIGN", 
                      "ENTERTAINMENT", "FAMILY", "FAMILY_ACTION", "FAMILY_BRAINGAMES", "GAME_ADVENTURE", 
                      "GAME_BOARD", "GAME_EDUCATIONAL", "GAME_ROLE_PLAYING", "GAME_SIMULATION", 
                      "GAME_STRATEGY", "GAME_TRIVIA", "HOUSE_AND_HOME", "MEDICAL", "MUSIC_AND_AUDIO", "NEWS_AND_MAGAZINES", 
                      "PHOTOGRAPHY", "PRODUCTIVITY", "ANDROID_WEAR", "BEAUTY", "EVENTS", "FAMILY_MUSICVIDEO", "FINANCE", 
                      "FOOD_AND_DRINK", "GAME", "GAME_ACTION", "GAME_RACING", "LIFESTYLE", "OVERALL", "SOCIAL", "SPORTS"]
    
    RankingsAccessor.any_instance.stub(:android_categories) { mock_response }
    get(:get_android_category_objects)
    categories = JSON.parse(@response.body).sort_by {|x| x["id"]}

    # From Fixtures
    assert_equal categories[0], {"name" => 'Education', "id" => 'EDUCATION', "platform" => 'android'}
    assert_equal categories[1], {"name" => 'Sports (Games)', "id" => 'GAME_SPORTS', "platform" => 'android'}
    assert_equal categories[2], {"name" => 'Sports', "id" => 'SPORTS', "platform" => 'android'}
  end

end
