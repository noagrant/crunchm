class Product < ActiveRecord::Base
  belongs_to :comparison
  has_many :tributes

end
