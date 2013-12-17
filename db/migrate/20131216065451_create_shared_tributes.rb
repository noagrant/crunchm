class CreateSharedTributes < ActiveRecord::Migration
  def change
    create_table :shared_tributes do |t|
      t.string :name
      t.float :weight
      t.references :comparison, index: true

      t.timestamps
    end
  end
end
