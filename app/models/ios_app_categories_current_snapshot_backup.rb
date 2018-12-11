# == Schema Information
#
# Table name: ios_app_categories_current_snapshot_backups
#
#  id                          :integer          not null, primary key
#  ios_app_category_id         :integer
#  ios_app_current_snapshot_id :integer
#  kind                        :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

class IosAppCategoriesCurrentSnapshotBackup < ActiveRecord::Base
  belongs_to :ios_app_category

  belongs_to :ios_app_current_snapshot_backup, foreign_key: 'ios_app_current_snapshot_id'

  enum kinds: [:primary, :secondary] 
end
