class AddSummaryToAndroidSdks < ActiveRecord::Migration
  def change
    add_column :android_sdks, :summary, :text
  end
end
