class AddStatusIndexToCompanies < ActiveRecord::Migration
  def change
    add_index :companies, :status
  end
end
