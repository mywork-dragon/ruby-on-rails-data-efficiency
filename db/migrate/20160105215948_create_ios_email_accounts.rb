class CreateIosEmailAccounts < ActiveRecord::Migration
  def change
    create_table :ios_email_accounts do |t|
      t.string :email
      t.string :password
      t.boolean :flagged

      t.timestamps
    end

    add_index :ios_email_accounts, :email, unique: true
  end
end
