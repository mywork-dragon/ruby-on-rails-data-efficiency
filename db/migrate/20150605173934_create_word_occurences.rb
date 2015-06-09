class CreateWordOccurences < ActiveRecord::Migration
  def change
    create_table :word_occurences do |t|
      t.string :word
      t.integer :good
      t.integer :bad

      t.timestamps
    end
    add_index :word_occurences, :word
  end
end
