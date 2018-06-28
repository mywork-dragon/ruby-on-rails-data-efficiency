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

  def test_get_device_fb_accounts
    fb_account = FbAccount.create!(:username => "zergling@mightysignal.com", :password => "overlord")
    @device1.fb_accounts << fb_account
    @device1.save

    @controller.stub :authenticate_admin_account, nil do
      response = get(:get_device_fb_accounts, {:id => @device1.id})
      data = JSON.parse(response.body)
      assert_equal 200, response.status
      assert_equal 1, data['fb_accounts'].length
    end
  end

  def test_get_device_apple_account_email
    apple_account = AppleAccount.create!(:email => "zergling@mightysignal.com", :password => "overlord")
    @device1.apple_account = apple_account
    @device1.save

    @controller.stub :authenticate_admin_account, nil do
      response = get(:get_device_apple_account_email, {:id => @device1.id})
      data = JSON.parse(response.body)
      assert_equal 200, response.status
      assert_equal apple_account.email, data['device_email']
    end
  end

  def test_enable_device
    @controller.stub :authenticate_admin_account, nil do
      @device1.update(:disabled => true)
      response = put(:enable_device, {:id => @device1.id})
      data = JSON.parse(response.body)
      assert_equal 200, response.status
      assert_not IosDevice.find(@device1.id).disabled
    end
  end

  def test_disable_device
    @controller.stub :authenticate_admin_account, nil do
      @device1.update(:disabled => false)
      response = put(:disable_device, {:id => @device1.id})
      data = JSON.parse(response.body)
      assert_equal 200, response.status
      assert IosDevice.find(@device1.id).disabled
    end
  end

  def test_enable_disable_device_not_found
    @controller.stub :authenticate_admin_account, nil do
      disable_response = put(:disable_device, {:id => 500})
      enable_response = put(:enable_device, {:id => 500})
      
      assert_equal 404, disable_response.status
      assert_equal 404, enable_response.status
    end
  end

  def test_enable_disable_device_no_id
    @controller.stub :authenticate_admin_account, nil do
      response = put(:disable_device)
      response = put(:enable_device)
      
      assert_equal 404, response.status
      assert_equal 404, response.status
    end
  end

end
