class ChangeDomainDatumLatLng < ActiveRecord::Migration
  def change
    change_column :domain_data, :lng, :decimal, :precision => 10, :scale => 6
    change_column :domain_data, :lat, :decimal, :precision => 10, :scale => 6
    remove_index :domain_data, :domain
    add_index :domain_data, :domain, unique: true
  end
end
