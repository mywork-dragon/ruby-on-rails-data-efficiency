# == Schema Information
#
# Table name: app_stores_ios_apps
#
#  id           :integer          not null, primary key
#  app_store_id :integer
#  ios_app_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class AppStoresIosApp < ActiveRecord::Base
  
  belongs_to :app_store
  belongs_to :ios_app

  class << self
    def clean_disabled_stores
      joins(:app_store)
        .where('app_stores.enabled = false')
        .delete_all
    end
  end
end
