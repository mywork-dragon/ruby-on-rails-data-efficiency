class CreateIpaSnapshots < ActiveRecord::Migration
  def change
    create_table :ipa_snapshots do |t|
    	t.integer :ios_app_id
    	t.integer :class_dump_id

      t.timestamps
    end
    add_index :ipa_snapshots, :ios_app_id
    add_index :ipa_snapshots, :class_dump_id
  end
end
