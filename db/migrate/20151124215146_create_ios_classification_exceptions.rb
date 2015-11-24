class CreateIosClassificationExceptions < ActiveRecord::Migration
  def change
    create_table :ios_classification_exceptions do |t|
      t.integer :ipa_snapshot_id
      t.text :error
      t.text :backtrace
      t.timestamps
    end

    add_index :ios_classification_exceptions, :ipa_snapshot_id
  end
end
