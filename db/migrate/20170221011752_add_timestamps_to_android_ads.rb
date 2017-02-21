class AddTimestampsToAndroidAds < ActiveRecord::Migration
  def change

    change_table "android_ads" do |t|
      t.timestamps
      t.datetime :date_seen
    end
  end
end
