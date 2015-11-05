class AddErrorBacktraceCocoapodIdToCocooapodExceptions < ActiveRecord::Migration
  def change
    add_column :cocoapod_exceptions, :cocoapod_id, :integer
    add_column :cocoapod_exceptions, :error, :string
    add_column :cocoapod_exceptions, :backtrace, :text

    add_index :cocoapod_exceptions, :cocoapod_id
    add_index :cocoapod_exceptions, :error
  end
end
