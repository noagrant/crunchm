class Comparison < ActiveRecord::Base
  belongs_to :user
  has_many :products 
  has_many :tributes

  accepts_nested_attributes_for :products
  accepts_nested_attributes_for :tributes

end
