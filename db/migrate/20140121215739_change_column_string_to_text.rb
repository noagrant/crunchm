class ChangeColumnStringToText < ActiveRecord::Migration
  def change
  	  	change_column :tributes, :value, :text, limit:nil
  end
end
