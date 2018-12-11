# == Schema Information
#
# Table name: app_store_scaling_factors
#
#  id                              :integer          not null, primary key
#  app_store_id                    :integer
#  ratings_all_count               :float(24)
#  ratings_per_day_current_release :float(24)
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#

class AppStoreScalingFactor < ActiveRecord::Base
  belongs_to :app_store
end
