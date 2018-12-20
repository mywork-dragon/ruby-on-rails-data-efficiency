# == Schema Information
#
# Table name: app_stores_ios_app_backups
#
#  id           :integer          not null, primary key
#  ios_app_id   :integer
#  app_store_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class AppStoresIosAppBackup < ActiveRecord::Base
  belongs_to :ios_app
  belongs_to :app_store
end
