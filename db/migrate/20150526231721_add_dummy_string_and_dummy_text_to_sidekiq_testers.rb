class AddDummyStringAndDummyTextToSidekiqTesters < ActiveRecord::Migration
  def change
    add_column :sidekiq_testers, :dummy_string, :string
    add_column :sidekiq_testers, :dummy_text, :text
  end
end
