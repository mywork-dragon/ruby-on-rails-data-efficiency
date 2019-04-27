class AddQualityToClearbitContact < ActiveRecord::Migration
  def change
    add_column :clearbit_contacts, :quality, :integer
  end
end
