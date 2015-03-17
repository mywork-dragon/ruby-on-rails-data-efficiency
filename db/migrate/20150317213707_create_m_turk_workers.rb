class CreateMTurkWorkers < ActiveRecord::Migration
  def change
    create_table :m_turk_workers do |t|
      t.integer :worker_identifier
      t.integer :age
      t.string :gender
      t.string :city
      t.string :state
      t.string :country
      t.string :iphone
      t.string :ios_version
      t.string :heroku_identifier

      t.timestamps
    end
  end
end
