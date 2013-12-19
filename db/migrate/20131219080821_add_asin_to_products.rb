class AddAsinToProducts < ActiveRecord::Migration
  def change
    add_column :products, :asin, :string
    add_index :products, :asin
  end
end
