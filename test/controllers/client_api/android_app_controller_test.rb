require 'test_helper'
require 'action_controller'

class ClientApi::AndroidAppControllerTest < ActionController::TestCase
  
  def setup
    ApplicationController.any_instance.stub(:limit_client_api_call) { true }
    ApiRequestAnalytics.any_instance.stub(:log_request) { true }
    @app = AndroidApp.create!(app_identifier: 'com.mighty.fun')
  end

  test "GET request works with MightySignal ID." do
    get(:show, {'id' => @app.id})
    assert JSON.parse(@response.body)['id']
  end
  
  test "GET request works with app_identifier." do
    get(:show, {'app_identifier' => 'com.mighty.fun'})
    assert JSON.parse(@response.body)['id']
  end

  
end
