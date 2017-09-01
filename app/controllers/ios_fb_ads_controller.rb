class IosFbAdsController < ApplicationController

  skip_before_action :verify_authenticity_token
  before_action :authenticate_admin_account

  def create_scrape_job
    job = IosFbAdJob.create({
      :job_type => 0
    })
    render json: { success: true, job_id: job.id }, status: 200
  end

  # Expects body to contain following keys:
  #   
  #   Required:
  #     ad_screenshot (base64)
  #     link_contents
  #     ios_fb_ad_job_id
  #     fb_account_id
  #     ios_device_id
  #
  #   Optional:
  #     ad_info_screenshot (base64)
  #     ad_info_html
  #     carousel
  #     feed_index
  #     open_proxy_id
  def upload_ad
    ensure_required_params!(params)
    screenshot_helper = TempScreenshotHelper.new

    begin
      row = {}

      row[:link_contents] = params[:link_contents]
      row[:ios_fb_ad_job_id] = params[:ios_fb_ad_job_id]
      row[:fb_account_id] = params[:fb_account_id]
      row[:ios_device_id] = params[:ios_device_id]
      ad_image_file = screenshot_helper.temp_image_file(params[:ad_screenshot])
      row[:ad_image] = ad_image_file

      row[:ad_info_html] = params[:ad_info_html] if params[:ad_info_html]
      row[:carousel] = params[:carousel] if params[:carousel]
      row[:feed_index] = params[:feed_index] if params[:feed_index]
      row[:open_proxy_id] = params[:open_proxy_id] if params[:open_proxy_id]

      if params[:ad_info_screenshot]
        ad_info_image_file = screenshot_helper.temp_image_file(params[:ad_info_screenshot])
        row[:ad_info_image] = ad_info_image_file
      end

      row[:status] = :preprocessed

      fb_ad = IosFbAd.create!(row)
    ensure
      if ad_image_file
        ad_image_file.close
        ad_image_file.unlink
      end

      if ad_info_image_file
        ad_info_image_file.close
        ad_info_image_file.unlink
      end
    end

    render json: { success: true, id: fb_ad.id }, status: 200
  end
  
  def ensure_required_params!(request_data)
    required_fields = [ :ad_screenshot, :link_contents, :ios_fb_ad_job_id, :fb_account_id, :ios_device_id ]
    required_fields.each do |required_field|
      raise "Missing required field #{required_field}" unless request_data.key?(required_field)
    end
  end
end