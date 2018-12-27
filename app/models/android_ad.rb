# == Schema Information
#
# Table name: android_ads
#
#  id                               :integer          not null, primary key
#  ad_type                          :integer
#  android_device_sn                :text(65535)
#  ad_id                            :text(65535)
#  source_app_id                    :integer
#  advertised_app_identifier        :text(65535)
#  advertised_app_id                :integer
#  facebook_account                 :text(65535)
#  google_account                   :text(65535)
#  ad_text                          :text(65535)
#  target_location                  :text(65535)
#  target_max_age                   :integer
#  target_min_age                   :integer
#  target_similar_to_existing_users :boolean
#  target_gender                    :text(65535)
#  target_education                 :text(65535)
#  target_existing_users            :boolean
#  target_facebook_audience         :text(65535)
#  target_language                  :text(65535)
#  target_relationship_status       :text(65535)
#  target_interests                 :text(65535)
#  target_proximity_to_business     :boolean
#  created_at                       :datetime
#  updated_at                       :datetime
#  date_seen                        :datetime
#

class AndroidAd < ActiveRecord::Base
  # The ad type eg mobile_app, website, etc..
  enum ad_type: [:mobile_app]
  belongs_to :source_app, class_name: 'AndroidApp', foreign_key: 'source_app_id'
  belongs_to :advertised_app, class_name:'AndroidApp', foreign_key: 'advertised_app_id'
  serialize :target_interests

  default_scope { order(date_seen: :desc) }

  def screenshot_url
    "https://s3.amazonaws.com/ms-android-automation-outputs/#{self.ad_id}/screenshot.png"
  end

  def as_json(options={})
    result = {
      id: self.id,
      ad_image: self.screenshot_url,
      # ad_attribution_sdks: self.advertised_app.ad_attribution_sdks,
      date_seen: self.date_seen
    }
    result[:app] = self.source_app unless options[:no_app]
    result
  end

end
