# == Schema Information
#
# Table name: ios_app_snapshots_languages
#
#  id                  :integer          not null, primary key
#  ios_app_snapshot_id :integer
#  ios_app_language_id :integer
#  created_at          :datetime
#  updated_at          :datetime
#

class IosAppSnapshotsLanguage < ActiveRecord::Base
  belongs_to :ios_app_snapshot
  belongs_to :ios_app_language
end
