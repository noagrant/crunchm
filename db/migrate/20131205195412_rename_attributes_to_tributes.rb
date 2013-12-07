class RenameAttributesToTributes < ActiveRecord::Migration
  def change
  	rename_table :attributes, :tributes
  end
end
