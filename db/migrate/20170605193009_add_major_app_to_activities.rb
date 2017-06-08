class AddMajorAppToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :major_app, :boolean, default: false
  end
end
