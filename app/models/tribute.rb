class Tribute < ActiveRecord::Base
  belongs_to :product
  belongs_to :comparison
end
