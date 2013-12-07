class AddRankingToProducts < ActiveRecord::Migration
  def change
  	add_column :products, :ranking, :integer
  end
end
