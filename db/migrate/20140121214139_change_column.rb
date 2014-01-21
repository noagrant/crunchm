class ChangeColumn < ActiveRecord::Migration
  def change
  	change_column :tributes, :name, :text
  end
end
