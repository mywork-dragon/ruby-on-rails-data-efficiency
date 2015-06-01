class AddIsItMediumTextToDummyModels < ActiveRecord::Migration
  def change
    add_column :dummy_models, :is_it_medium_text, :text
  end
end
