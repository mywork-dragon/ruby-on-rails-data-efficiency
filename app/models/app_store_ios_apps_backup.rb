class AppStoreIosAppsBackup < ActiveRecord::Base
  belongs_to :ios_app
  belongs_to :app_store
end
