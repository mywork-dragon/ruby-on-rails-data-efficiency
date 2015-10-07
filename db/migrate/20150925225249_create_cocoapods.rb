class CreateCocoapods < ActiveRecord::Migration
  def change
    create_table :cocoapods do |t|
    	t.string :name
    	t.string :version
    	t.text :summary
    	t.text :link
    	t.boolean :cocoadocs
      t.text :git
      t.text :http
      t.string :tag

      t.timestamps
    end
    add_index :cocoapods, [:name, :version], unique: true
    add_index :cocoapods, :cocoadocs
  end
end
