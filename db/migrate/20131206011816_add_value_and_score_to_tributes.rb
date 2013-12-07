class AddValueAndScoreToTributes < ActiveRecord::Migration
  def change
    add_column :tributes, :value, :string
    add_column :tributes, :score, :float
  end
end
