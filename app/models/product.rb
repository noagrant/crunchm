class Product < ActiveRecord::Base
  belongs_to :comparison
  has_many :tributes
    accepts_nested_attributes_for :tributes

end
