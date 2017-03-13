class AddFortune1000RankToDomainData < ActiveRecord::Migration
  def change
    add_column :domain_data, :fortune_1000_rank, :integer
    add_index :domain_data, :fortune_1000_rank
  end
end
