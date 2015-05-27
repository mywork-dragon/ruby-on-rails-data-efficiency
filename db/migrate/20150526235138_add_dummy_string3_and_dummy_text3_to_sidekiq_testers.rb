class AddDummyString3AndDummyText3ToSidekiqTesters < ActiveRecord::Migration
  def change
    add_column :sidekiq_testers, :dummy_string3, :string
    add_column :sidekiq_testers, :dummy_text3, :text
  end
end
