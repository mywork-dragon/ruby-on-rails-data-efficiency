class AndroidAd < ActiveRecord::Base
  # The ad type eg mobile_app, website, etc..
  enum ad_type: [:mobile_app]
  belongs_to :source_app, class_name: 'AndroidApp', foreign_key: 'source_app_id'
  belongs_to :advertised_app, class_name:'AndroidApp', foreign_key: 'advertised_app_id'
  serialize :target_interests

  def screenshot_url
    "https://s3.amazonaws.com/ms-android-automation-outputs/#{self.ad_id}/screenshot.png"
  end

end
