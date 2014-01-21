class ChangeColumnTypeStringToText < ActiveRecord::Migration
  def change
  	  	change_column :tributes, :name, :text, limit:nil
  	  	change_column :tributes, :value, :text, limit:nil
  	  	change_column :shared_tributes, :name, :text, limit:nil
  	  	change_column :products, :name, :text, limit:nil
  end
end
