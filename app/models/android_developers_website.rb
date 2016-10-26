class AndroidDevelopersWebsite < ActiveRecord::Base
  belongs_to :android_developer
  belongs_to :website

  before_create :set_is_valid

  def set_is_valid
    if android_developer && website 
      valid_dev_ids = ClearbitWorker::ANDROID_DEVELOPER_IDS[website.domain]
      self.is_valid = !valid_dev_ids || valid_dev_ids.include?(android_developer.id) 
    end
  end
end
