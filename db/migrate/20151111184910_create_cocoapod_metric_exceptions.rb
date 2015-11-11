class CreateCocoapodMetricExceptions < ActiveRecord::Migration
  def change
    create_table :cocoapod_metric_exceptions do |t|

      t.integer :cocoapod_metric_id
      t.text :error
      t.text :backtrace

      t.timestamps
    end

    add_index :cocoapod_metric_exceptions, :cocoapod_metric_id
  end
end
