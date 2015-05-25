require 'test_helper'

require 'action_controller'

class ApiControllerTest < ActionController::TestCase
  
  # def setup
  #   puts "SETUP API"
  # end
  #
  # # called after every single test
  # def teardown
  #   puts "TURRDOWN"
  # end
  
  # test "Should filter correctly for Mobile Priority" do
  #   puts "cols: #{IosApp.column_names}"
  #   ios_app = IosApp.create!(app_identifier: 123, mobile_priority: :medium)
  #
  #   ios_app_snapshot = IosAppSnapshot.create
  #
  #   ios_app.newest_ios_app_snapshot = ios_app_snapshot
  #   ios_app.save
  #
  #   post(:filter_ios_apps, {'app' => {'mobilePriority' => "M"}})
  #   puts "response: #{@response.body}"
  #
  #   puts "ios_app: #{IosApp.find_by_app_identifier(123).app_identifier}"
  #
  #   assert true
  # end
  
  # test 'should fail' do
  #   assert false
  # end
  #
    
end
