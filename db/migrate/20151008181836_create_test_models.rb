class CreateTestModels < ActiveRecord::Migration
  def change
    create_table :test_models do |t|
      t.string :string0
      t.string :string1
      t.string :string2
      t.string :string3
      t.string :string4
      t.string :string5
      t.string :string6
      t.string :string7
      t.string :string8
      t.string :string9
      t.string :string10
      t.string :string11
      t.string :string12
      t.string :string13
      t.string :string14
      t.string :string15
      t.string :string16
      t.string :string17
      t.string :string18
      t.string :string19

      t.timestamps
    end
    add_index :test_models, :string0
    add_index :test_models, :string1
    add_index :test_models, :string2
    add_index :test_models, :string3
    add_index :test_models, :string4
    add_index :test_models, :string5
    add_index :test_models, :string6
    add_index :test_models, :string7
    add_index :test_models, :string8
    add_index :test_models, :string9
    add_index :test_models, :string10
    add_index :test_models, :string11
    add_index :test_models, :string12
    add_index :test_models, :string13
    add_index :test_models, :string14
    add_index :test_models, :string15
    add_index :test_models, :string16
    add_index :test_models, :string17
    add_index :test_models, :string18
    add_index :test_models, :string19
  end
end
