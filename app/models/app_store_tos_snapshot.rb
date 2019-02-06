# == Schema Information
#
# Table name: app_store_tos_snapshots
#
#  id                :integer          not null, primary key
#  app_store_id      :integer
#  last_updated_date :date
#  good_as_of_date   :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

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
