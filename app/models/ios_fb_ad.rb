class IosFbAd < ActiveRecord::Base

  belongs_to :ios_fb_ad_job
  belongs_to :ios_device
  belongs_to :fb_account
  belongs_to :ios_app

  has_many :ios_fb_ad_processing_exceptions

  enum status: [:preprocessed, :processing, :complete, :failed]

  has_attached_file :ad_image, 
    PaperclipSettings.obfuscation_defaults.merge(
    {
      bucket: Proc.new {|a| a.instance.get_s3_bucket}
    })
  validates_attachment_file_name :ad_image, :matches => [/png\Z/i]

  has_attached_file :ad_info_image, 
    PaperclipSettings.obfuscation_defaults.merge(
    {
      bucket: Proc.new {|a| a.instance.get_s3_bucket}
    })
  validates_attachment_file_name :ad_info_image, :matches => [/png\Z/i]

  before_create :set_date_seen

  def set_date_seen
    self.date_seen = self.date_seen || Time.now
  end

  def get_s3_bucket
    "ms-ios-fb-ads" if Rails.env.production?
  end
end
