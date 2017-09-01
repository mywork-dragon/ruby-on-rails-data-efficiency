require 'test_helper'
require 'action_controller'
require 'json'
require 'mocks/temp_screenshot_helper_mock'

class IosFbAdsControllerTest < ActionController::TestCase

  def setup
    @sample_ad_base64 = File.open(File.join(Rails.root, 'test', 'data', 'sample_ad_base64.txt')).read
    @sample_link_content = "https://itunes.apple.com/us/app/quickbooks-self-employed-mile-tracker-taxes/id898076976?mt=8"
    @sample_ios_fb_ad = IosFbAd.new(:id => 5)
  end

  def test_create_scrape_job
    @controller.stub :authenticate_admin_account, nil do
      response = post(:create_scrape_job)
      data = JSON.parse(response.body)
      
      assert_equal 200, response.status
      assert data["job_id"]
      assert IosFbAdJob.find(data["job_id"])
    end
  end

  def test_upload_ad_empty_params
    @controller.stub :authenticate_admin_account, nil do
      IosFbAd.stub :create!, @sample_ios_fb_ad do
        assert_raise RuntimeError do
          response = post(:upload_ad, {})
        end
      end
    end
  end

  def test_upload_ad_missing_link_content
    @controller.stub :authenticate_admin_account, nil do
      IosFbAd.stub :create!, @sample_ios_fb_ad do
        assert_raise RuntimeError do
          response = post(:upload_ad, {
            :ad_screenshot => @sample_ad_base64,
            :ios_fb_ad_job_id => 1,
            :fb_account_id => 1,
            :ios_device_id => 1
          })
        end
      end
    end
  end

  def test_upload_ad
    mock_file = MiniTest::Mock.new
    mock_file.expect(:close, nil)
    mock_file.expect(:unlink, nil)
    screenshot_helper_mock = TempScreenshotHelperMock.new(mock_file)

    @controller.stub :authenticate_admin_account, nil do
      IosFbAd.stub :create!, @sample_ios_fb_ad do
        TempScreenshotHelper.stub :new, screenshot_helper_mock do
          response = post(:upload_ad, {
            :ad_screenshot => @sample_ad_base64,
            :link_contents => @sample_link_content,
            :ios_fb_ad_job_id => 1,
            :fb_account_id => 1,
            :ios_device_id => 1
          })

          data = JSON.parse(response.body)
          assert_equal 200, response.status
          assert_equal @sample_ios_fb_ad.id, data["id"]
          mock_file.verify
        end
      end
    end
  end

end
