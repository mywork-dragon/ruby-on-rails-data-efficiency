class RemoveRecommendedAgeFromAndroidAppReleases < ActiveRecord::Migration
  def change
    
    remove_column :android_app_releases, :recommended_age
    
  end
end
