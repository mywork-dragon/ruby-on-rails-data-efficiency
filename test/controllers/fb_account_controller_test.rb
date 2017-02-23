require 'test_helper'
require 'action_controller'

class FbAccountControllerTest < ActionController::TestCase
  def setup
    @available_account = FbAccount.create!(id: 1, username: 'available', password: 'mypassword', purpose: :ios_ad_spend, in_use: false)
    @busy_account = FbAccount.create!(id: 2, username: 'busy', purpose: :mau_scrape, in_use: true)
  end

  def test_bad_request_for_invalid_purposes
    @controller.stub :authenticate_admin_account, nil do
      assert_equal 400, put(:reserve).status
      assert_equal 400, put(:reserve, { purpose: :hello }).status
    end
  end

  def test_unavailable
    @controller.stub :authenticate_admin_account, nil do
      assert_equal 404, put(:reserve, { purpose: :mau_scrape }).status
    end
  end

  def test_available
    @controller.stub :authenticate_admin_account, nil do
      res = put(:reserve, { purpose: :ios_ad_spend })
      assert_equal 200, res.status

      body = JSON.parse(res.body)
      assert_equal @available_account.id, body['id']
      assert_equal @available_account.username, body['username']
      assert_equal @available_account.password, body['password']
    end
  end

  def test_release_invalid_request
    @controller.stub :authenticate_admin_account, nil do
      assert_equal 400, put(:release).status
      assert_equal 400, put(:release, { id: 'not a real number' }).status
    end
  end

  def test_invalid_id
    @controller.stub :authenticate_admin_account, nil do
      assert_equal 404, put(:release, { id: -123123 }).status
      assert_equal 404, put(:release, { id: 567 }).status
    end
  end

  def test_release_success
    @controller.stub :authenticate_admin_account, nil do
      assert_equal 200, put(:release, { id: 2 }).status

      res = put(:reserve, { purpose: :mau_scrape })
      assert_equal 200, res.status
      assert_equal @busy_account.id, JSON.parse(res.body)['id']
    end
  end
end
