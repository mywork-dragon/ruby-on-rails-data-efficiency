class AddAndroidAds < ActiveRecord::Migration
  def change
    create_table "android_ads" do |t|
      t.integer  "ad_type", limit: 4
      t.text     "android_device_sn", limit: 1024
      t.text     "ad_id", limit: 1024
      t.integer  "source_app_id", limit: 4
      t.text     "advertised_app_identifier", limit: 1024
      t.integer  "advertised_app_id", limit: 4
      t.text     "facebook_account", limit: 1024
      t.text     "google_account", limit: 1024
      t.text     "ad_text", limit: 1024
      t.text     "target_location", limit: 1024
      t.integer  "target_max_age", limit: 4
      t.integer  "target_min_age", limit: 4
      t.boolean  "target_similar_to_existing_users"
      t.text     "target_gender", limit: 1024
      t.text     "target_education", limit: 1024
      t.boolean  "target_existing_users"
      t.text     "target_facebook_audience", limit: 1024
      t.text     "target_language", limit: 1024
      t.text     "target_relationship_status", limit: 1024
      t.text     "target_interests", limit: 1024
      t.boolean  "target_proximity_to_business"
    end
  end
end

