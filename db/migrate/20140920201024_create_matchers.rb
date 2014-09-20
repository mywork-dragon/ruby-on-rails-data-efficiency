class CreateMatchers < ActiveRecord::Migration
  def change
    create_table :matchers do |t|
      t.belongs_to :service
      t.integer :match_type
      t.text :match_string
      t.timestamps
    end
    add_index :matchers, :service_id
  end
end
