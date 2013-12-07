class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.text :url
      t.references :comparison, index: true

      t.timestamps
    end
  end
end
