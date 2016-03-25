class WeeklyBatchesActivity < ActiveRecord::Base
  belongs_to :weekly_batch, counter_cache: :activities_count
  belongs_to :activity
end
