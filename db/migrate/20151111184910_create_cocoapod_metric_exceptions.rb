class CreateCocoapodMetricExceptions < ActiveRecord::Migration
  def change
    create_table :cocoapod_metric_exceptions do |t|

      t.integer :ios_sdk_id
      t.text :error
      t.text :backtrace 

      t.timestamps
    end

    add_index :cocoapod_metric_exceptions, :ios_sdk_id
  end
end
