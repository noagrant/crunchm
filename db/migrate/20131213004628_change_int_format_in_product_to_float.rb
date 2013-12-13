class ChangeIntFormatInProductToFloat < ActiveRecord::Migration
  def change
  	change_column :products, :ranking, :float
 	
  end
end
