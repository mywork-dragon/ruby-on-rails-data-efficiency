class CreateFbStatuses < ActiveRecord::Migration
  def change
    create_table :fb_statuses do |t|
      t.text :status
      t.timestamps
    end
  end
end
