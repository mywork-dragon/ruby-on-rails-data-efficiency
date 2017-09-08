class IosFbAd < ActiveRecord::Base

  belongs_to :ios_fb_ad_job
  belongs_to :ios_device
  belongs_to :fb_account
  belongs_to :ios_app
  belongs_to :softlayer_proxy
  belongs_to :open_proxy

  has_many :ios_fb_ad_processing_exceptions
  has_many :weekly_batches, as: :owner

  enum status: [:preprocessed, :processing, :complete, :failed]

  default_scope { order(date_seen: :desc) }
  scope :has_image, -> { where(ios_fb_ad_appearances_id: nil, flagged: false) }

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
    if Rails.env.production?
      "ms-ios-fb-ads"
    else
      "ms-ios-fb-ads-staging"
    end
  end

  def invalidate
    self.update(flagged: true)
    self.weekly_batches.each do |batch|
      batch.activities.destroy_all
      batch.destroy if batch.activities.count == 0
    end
  end

  def to_csv_row
    ios_app.to_csv_row
  end

  def as_json(options={})
    result = {
      id: self.id,
      ad_image: self.ad_image? ? self.ad_image : nil,
      ad_info_image: self.ad_info_image? ? self.ad_info_image : nil,
      #ad_attribution_sdks: self.ios_app.ad_attribution_sdks,
      date_seen: self.date_seen
    }
    result[:app] = self.ios_app unless options[:no_app]
    result
  end
end
