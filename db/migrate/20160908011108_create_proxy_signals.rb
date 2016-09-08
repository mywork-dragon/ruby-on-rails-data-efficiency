class CreateProxySignals < ActiveRecord::Migration
  def change
    create_table :proxy_signals do |t|
      t.boolean :activated
      t.datetime :updated_time
      t.timestamps null: false
    end

    add_index :proxy_signals, :activated
  end
end
