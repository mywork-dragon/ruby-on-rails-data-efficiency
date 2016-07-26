class CreateEpfApplications < ActiveRecord::Migration
  def change
    create_table :epf_applications do |t|
      t.integer :export_date, limit: 8
      t.integer :application_id, null: false
      t.text :title
      t.text :recommended_age
      t.text :artist_name
      t.text :seller_name
      t.text :company_url
      t.text :support_url
      t.text :view_url
      t.text :artwork_url_large
      t.text :artwork_url_small
      t.datetime :itunes_release_date
      t.text :copyright
      t.text :description
      t.text :version
      t.text :itunes_version
      t.integer :download_size, limit: 8

      t.timestamps null: false
    end

    add_index :epf_applications, :application_id, unique: true
  end
end
