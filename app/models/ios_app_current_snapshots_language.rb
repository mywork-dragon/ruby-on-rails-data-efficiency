class IosAppCurrentSnapshotsLanguage < ActiveRecord::Base

  belongs_to :ios_app_current_snapshot
  belongs_to :ios_app_language

end