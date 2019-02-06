# == Schema Information
#
# Table name: android_developers_websites
#
#  id                   :integer          not null, primary key
#  android_developer_id :integer
#  website_id           :integer
#  created_at           :datetime
#  updated_at           :datetime
#  is_valid             :boolean          default(TRUE)
#

class AndroidDevelopersWebsite < ActiveRecord::Base
  belongs_to :android_developer
  belongs_to :website

  before_create :set_is_valid

  def set_is_valid
    if android_developer && website 
      valid_dev_ids = ClearbitWorker::ANDROID_DEVELOPER_IDS[website.domain]
      self.is_valid = !valid_dev_ids || valid_dev_ids.include?(android_developer.id) 
    end
    true
  end
end
