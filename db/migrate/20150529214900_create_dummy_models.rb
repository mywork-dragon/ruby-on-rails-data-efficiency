class CreateDummyModels < ActiveRecord::Migration
  def change
    create_table :dummy_models do |t|
      t.string :dummy
      t.text :dummy_text

      t.timestamps
    end
  end
end
