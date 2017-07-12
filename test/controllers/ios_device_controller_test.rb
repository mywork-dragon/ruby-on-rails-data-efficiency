require 'test_helper'
require 'action_controller'
require 'json'

class IosDeviceControllerTest < ActionController::TestCase
  
  def setup
    @device1 = IosDevice.create!(:purpose => 1, :description => 'test 1', :serial_number => '1', :ip => '192.168.1.1')
    @device2 = IosDevice.create!(:purpose => 1, :description => 'test 2', :serial_number => '2', :ip => '192.168.1.2')
    @device3 = IosDevice.create!(:purpose => 2, :description => 'test 3', :serial_number => '3', :ip => '192.168.1.3')
  end

  def test_returns_all_when_no_params
    @controller.stub :authenticate_admin_account, nil do
      response = get(:filter)
      data = JSON.parse(response.body)
      assert_equal 200, response.status
      assert_equal 3, data.length
      assert data.find { |x| x['serial_number'] == '1' }
      assert data.find { |x| x['serial_number'] == '2' }
      assert data.find { |x| x['serial_number'] == '3' }
    end
  end

  def test_filters_by_purpose_param
    @controller.stub :authenticate_admin_account, nil do
      response = get(:filter, {:purpose => 1})
      data = JSON.parse(response.body)
      assert_equal 200, response.status
      assert_equal 2, data.length
      assert data.find { |x| x['serial_number'] == '1' }
      assert data.find { |x| x['serial_number'] == '2' }
      assert_nil data.find { |x| x['serial_number'] == '3' }
    end
  end

  def test_filters_by_id_param
    @controller.stub :authenticate_admin_account, nil do
      response = get(:filter, {:id => @device3.id})
      data = JSON.parse(response.body)
      assert_equal 200, response.status
      assert_equal 1, data.length
      assert_nil data.find { |x| x['serial_number'] == '1' }
      assert_nil data.find { |x| x['serial_number'] == '2' }
      assert data.find { |x| x['serial_number'] == '3' }
    end
  end

end
