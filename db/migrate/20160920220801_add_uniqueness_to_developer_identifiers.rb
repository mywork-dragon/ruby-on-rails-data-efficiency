class AddUniquenessToDeveloperIdentifiers < ActiveRecord::Migration
  def change
    remove_index :ios_developers, :identifier
    remove_index :android_developers, :identifier
    add_index :ios_developers, :identifier, unique: true
    add_index :android_developers, :identifier, unique: true
  end
end
