class AddIndexToFortune100RankOnCompanies < ActiveRecord::Migration
  def change
    add_index :companies, :fortune_1000_rank
  end
end
