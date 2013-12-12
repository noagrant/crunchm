class AddColsToTribute < ActiveRecord::Migration
  def change
    add_column :tributes, :group, :integer
    add_column :tributes, :placement, :integer
    add_column :tributes, :asin, :string
  end
end
