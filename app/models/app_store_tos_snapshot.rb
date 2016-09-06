class AppStoreTosSnapshot < ActiveRecord::Base
  belongs_to :app_store

  before_create :set_valid_date

  def set_valid_date
    self.good_as_of_date = Time.now
  end

  def touch_valid_date
    update!(good_as_of_date: Time.now)
  end
end
