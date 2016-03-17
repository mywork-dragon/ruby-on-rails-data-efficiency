class CreateWeeklyBatchesActivities < ActiveRecord::Migration
  def change
    create_table :weekly_batches_activities do |t|
      t.integer :weekly_batch_id, null: false
      t.integer :activity_id, null: false
      t.timestamps
    end
    add_index :weekly_batches_activities, :activity_id
    add_index :weekly_batches_activities, [:weekly_batch_id, :activity_id], name: 'weekly_batch_id_activity_id_index'
  end
end
