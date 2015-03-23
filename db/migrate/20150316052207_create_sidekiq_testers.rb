class CreateSidekiqTesters < ActiveRecord::Migration
  def change
    create_table :sidekiq_testers do |t|
      t.string :test_string
      t.string :ip

      t.timestamps
    end
  end
end
