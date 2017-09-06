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
      response = post(:create_scrape_job, {
            :notes => "Battlecruiser operational."
          })
      
      data = JSON.parse(response.body)
      job = IosFbAdJob.find(data["job_id"])

      assert_equal 200, response.status
      assert data["job_id"]
      assert job
      assert_equal "Battlecruiser operational.", job.notes
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

  def test_start_processing_calls_perform_async
    fb_ad = IosFbAd.create(:id => 10)
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, [fb_ad.id.to_s])

    @controller.stub :authenticate_admin_account, nil do
      IosFbProcessingWorker.stub :perform_async, mock do
        response = post(:start_processing, { :fb_ad_id => fb_ad.id })
        data = JSON.parse(response.body)
        assert_equal 200, response.status
        assert data['success']
      end
      mock.verify
    end
  end

  def test_start_processing_invalid_fb_ad_id
    @controller.stub :authenticate_admin_account, nil do
      assert_raise RuntimeError do
        response = post(:start_processing, { :fb_ad_id => 1234 })
        data = JSON.parse(response.body)
        assert_equal 200, response.status
        assert data['success']
      end
    end
  end

end
