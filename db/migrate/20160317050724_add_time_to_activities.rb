class AddTimeToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :happened_at, :datetime
  end
end
