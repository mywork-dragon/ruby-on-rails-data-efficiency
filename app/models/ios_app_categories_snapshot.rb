class IosAppCategoriesSnapshot < ActiveRecord::Base
  belongs_to :ios_app_category
  belongs_to :ios_app_snapshot
  enum type: [:primary, :secondary]
end
