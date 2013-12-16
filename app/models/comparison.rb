class Comparison < ActiveRecord::Base
  belongs_to :user
  has_many :products 
  has_many :tributes
  has_many :shared_tributes

  accepts_nested_attributes_for :products
  accepts_nested_attributes_for :tributes

  # should validate only for save!
  #validates :user_id, presence: true
end
