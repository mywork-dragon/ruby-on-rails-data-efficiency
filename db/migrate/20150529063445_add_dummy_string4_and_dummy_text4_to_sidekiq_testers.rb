class AddDummyString4AndDummyText4ToSidekiqTesters < ActiveRecord::Migration
  def change
    add_column :sidekiq_testers, :dummy_string4, :string
    add_column :sidekiq_testers, :dummy_text4, :text
  end
end
