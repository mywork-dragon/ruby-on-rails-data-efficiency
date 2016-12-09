class AddWebsiteFeatures < ActiveRecord::Migration
  def change
    create_table :website_features do |t|
      t.integer :user_id
      t.integer :name
      t.timestamp :last_used
    end

    add_index :website_features, [:user_id]
  end
end
