class IosAppSnapshotsLanguage < ActiveRecord::Base
  belongs_to :ios_app_snapshot
  belongs_to :ios_app_language
end
