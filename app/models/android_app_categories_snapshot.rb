# == Schema Information
#
# Table name: android_app_categories_snapshots
#
#  id                      :integer          not null, primary key
#  android_app_category_id :integer
#  android_app_snapshot_id :integer
#  created_at              :datetime
#  updated_at              :datetime
#  kind                    :integer
#

class AndroidAppCategoriesSnapshot < ActiveRecord::Base

  belongs_to :android_app_category
  belongs_to :android_app_snapshot
  
  enum kind: [:primary, :secondary]

end
