class AddTextsToTestModels < ActiveRecord::Migration
  def change
    add_column :test_models, :text0, :text

    add_column :test_models, :text1, :text

    add_column :test_models, :text2, :text
  end
end
