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
    get(:get_android_category_objects)
    categories = JSON.parse(@response.body).sort_by {|x| x["id"]}
    # From Fixtures
    assert_equal categories[0], {"name" => 'Education', "id" => 'EDUCATION'}
    assert_equal categories[1], {"name" => 'Sports', "id" => 'GAME_SPORTS'}
    assert_equal categories[2], {"name" => 'Sports', "id" => 'SPORTS'}
  end

end
