class WeeklyBatchesActivity < ActiveRecord::Base
  belongs_to :weekly_batch
  belongs_to :activity
end
