# == Schema Information
#
# Table name: ios_developers_websites
#
#  id               :integer          not null, primary key
#  ios_developer_id :integer
#  website_id       :integer
#  created_at       :datetime
#  updated_at       :datetime
#  is_valid         :boolean          default(TRUE)
#

class IosDevelopersWebsite < ActiveRecord::Base
  belongs_to :ios_developer
  belongs_to :website

  before_create :set_is_valid

  def set_is_valid
    if ios_developer && website 
      valid_dev_ids = ClearbitWorker::IOS_DEVELOPER_IDS[website.domain]
      self.is_valid = !valid_dev_ids || valid_dev_ids.include?(ios_developer.id) 
    end
    true
  end
end
