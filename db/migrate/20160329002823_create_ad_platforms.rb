class CreateAdPlatforms < ActiveRecord::Migration
  def change
    create_table :ad_platforms do |t|
      t.string :platform
      t.timestamps
    end
  end
end
