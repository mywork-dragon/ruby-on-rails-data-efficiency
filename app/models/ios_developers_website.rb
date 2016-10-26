class IosDevelopersWebsite < ActiveRecord::Base
  belongs_to :ios_developer
  belongs_to :website

  before_create :set_is_valid

  def set_is_valid
    if ios_developer && website 
      valid_dev_ids = ClearbitWorker::IOS_DEVELOPER_IDS[website.domain]
      self.is_valid = !valid_dev_ids || valid_dev_ids.include?(ios_developer.id) 
    end
  end
end
