# == Schema Information
#
# Table name: weekly_batches_activities
#
#  id              :integer          not null, primary key
#  weekly_batch_id :integer          not null
#  activity_id     :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#

class WeeklyBatchesActivity < ActiveRecord::Base
  belongs_to :weekly_batch, counter_cache: :activities_count
  belongs_to :activity
end
