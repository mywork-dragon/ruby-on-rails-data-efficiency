class CreateWeeklyBatches < ActiveRecord::Migration
  def change
    create_table :weekly_batches do |t|
      t.integer :owner_id
      t.string :owner_type
      t.integer :activity_type
      t.integer :activities_count, default: 0, null: false
      t.date :week, null: false
      t.timestamps
    end
    add_index :weekly_batches, :week
    add_index :weekly_batches, :activity_type
    add_index :weekly_batches, [:owner_id, :owner_type]
  end
end
