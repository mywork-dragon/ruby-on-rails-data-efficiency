class AddIndexToActivitiesHappenedAt < ActiveRecord::Migration
  def change
    add_index :activities, :happened_at
  end
end
