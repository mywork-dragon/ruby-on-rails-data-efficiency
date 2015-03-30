class IosAppCategory < ActiveRecord::Base
  has_many :ios_app_snapshots, through: :ios_app_categories_snapshots
end
