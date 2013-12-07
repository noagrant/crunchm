class CreateComparisons < ActiveRecord::Migration
  def change
    create_table :comparisons do |t|
      t.string :name
      t.text :note
      t.references :user, index: true

      t.timestamps
    end
  end
end
