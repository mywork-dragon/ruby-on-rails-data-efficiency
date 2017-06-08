class AddIndexToActivities < ActiveRecord::Migration
  def change

    add_index :activities, :major_app

  end
end
