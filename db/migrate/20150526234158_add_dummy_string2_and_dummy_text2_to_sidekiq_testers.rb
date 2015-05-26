class AddDummyString2AndDummyText2ToSidekiqTesters < ActiveRecord::Migration
  def change
    add_column :sidekiq_testers, :dummy_string2, :string
    add_column :sidekiq_testers, :dummy_text2, :text
  end
end
