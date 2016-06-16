class AddTimestampsToIosAppCategoryNames < ActiveRecord::Migration
  def change
    add_timestamps :ios_app_category_names
  end
end
