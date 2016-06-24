class IosAppCategoriesCurrentSnapshotBackup < ActiveRecord::Base
  belongs_to :ios_app_category

  belongs_to :ios_app_current_snapshot_backup, foreign_key: 'ios_app_current_snapshot_id'

  enum kinds: [:primary, :secondary] 
end
