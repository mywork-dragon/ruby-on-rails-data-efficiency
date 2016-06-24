class IosAppCategoryNameBackup < ActiveRecord::Base
  belongs_to :app_store
  belongs_to :ios_app_category
end
