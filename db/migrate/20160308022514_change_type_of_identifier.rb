class ChangeTypeOfIdentifier < ActiveRecord::Migration
  def change
    change_column :ios_developers, :identifier, :integer
  end
end
