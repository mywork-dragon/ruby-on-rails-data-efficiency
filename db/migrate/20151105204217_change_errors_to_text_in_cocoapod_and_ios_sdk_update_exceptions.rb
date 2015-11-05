class ChangeErrorsToTextInCocoapodAndIosSdkUpdateExceptions < ActiveRecord::Migration
  def change

    remove_index :cocoapod_exceptions, name: "index_cocoapod_exceptions_on_error"
    
    change_column :cocoapod_exceptions, :error, :text
    change_column :ios_sdk_update_exceptions, :error, :text
  end
end
