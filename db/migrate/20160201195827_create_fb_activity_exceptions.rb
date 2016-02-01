class CreateFbActivityExceptions < ActiveRecord::Migration
  def change
    create_table :fb_activity_exceptions do |t|
      t.integer :fb_account_id
      t.text :error
      t.text :backtrace
      t.timestamps
    end
  end
end
