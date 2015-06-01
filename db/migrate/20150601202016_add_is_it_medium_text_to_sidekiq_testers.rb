class AddIsItMediumTextToSidekiqTesters < ActiveRecord::Migration
  def change
    add_column :sidekiq_testers, :is_it_medium_text, :text
  end
end
