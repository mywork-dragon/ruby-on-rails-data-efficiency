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
