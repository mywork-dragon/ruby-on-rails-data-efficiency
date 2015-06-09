class AppStore < ActiveRecord::Base

  has_many :app_stores_ios_apps
  has_many :ios_apps, -> { uniq }, through: :app_stores_ios_apps

end
