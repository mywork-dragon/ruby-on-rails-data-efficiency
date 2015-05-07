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
  
  test "Should filter correctly for Mobile Priority" do
    post(:filter_ios_apps, {'app' => {'mobilePriority' => "H"}})
    puts "response: #{@response.body}"
    assert true
  end
end
