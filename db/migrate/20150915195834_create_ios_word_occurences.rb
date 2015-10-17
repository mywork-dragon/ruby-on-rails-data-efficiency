class CreateIosWordOccurences < ActiveRecord::Migration
  def change
    create_table :ios_word_occurences do |t|
    	t.string :word
      t.integer :count

      t.timestamps
    end
    add_index :ios_word_occurences, :word
    add_index :ios_word_occurences, :count
  end
end
