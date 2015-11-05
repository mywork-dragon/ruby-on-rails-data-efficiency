class CreateIosSdkUpdateExceptions < ActiveRecord::Migration
  def change
    create_table :ios_sdk_update_exceptions do |t|

      t.string :sdk_name
      t.integer :ios_sdk_update_id
      t.string :error
      t.text :backtrace
      t.timestamps
    end

    add_index :ios_sdk_update_exceptions, :sdk_name
    add_index :ios_sdk_update_exceptions, :ios_sdk_update_id
  end
end
