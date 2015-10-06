class CreateKnownIosWords < ActiveRecord::Migration
  def change
    create_table :known_ios_words do |t|
    	t.string :word

    	t.timestamp
    end
    add_index :known_ios_words, :word
  end
end
