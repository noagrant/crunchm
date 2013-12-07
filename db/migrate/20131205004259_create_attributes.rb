class CreateAttributes < ActiveRecord::Migration
  def change
    create_table :attributes do |t|
      t.string :name
      t.float :weight
      t.references :product, index: true
      t.references :comparison, index: true

      t.timestamps
    end
  end
end
