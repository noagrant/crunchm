class User < ActiveRecord::Base
	has_many :comparisons
end
