class IosAppCurrentSnapshotBackup < ActiveRecord::Base
  serialize :screenshot_urls, Array
  serialize :ios_in_app_purchases, Hash

  enum mobile_priority: [:high, :medium, :low]
  enum user_base: [:elite, :strong, :moderate, :weak]
end
