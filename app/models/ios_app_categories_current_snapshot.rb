class IosAppCategoriesCurrentSnapshot < ActiveRecord::Base

  belongs_to :ios_app_current_snapshot
  belongs_to :ios_app_category

  enum kinds: [:primary, :secondary] 

end