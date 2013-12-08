class User < ActiveRecord::Base
	
	has_many :comparisons
	accepts_nested_attributes_for :comparisons

	email_regex = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]+)\z/i

	validates :first_name,	presence:	true,
	  						length:		{ within: 2..50 }
	validates :last_name,	presence:	true,
	  						length:		{ within: 2..50 }
	validates :email,		presence:	true,
	  						format: 	{ with: email_regex, message: "Oops... not an email"},
	           				uniqueness: { case_sensitive: false }
	validates :password,    length:		{ within: 6..40 }

	before_save { self.email = email.downcase }
	
	# bcrypt requires this line:
	has_secure_password
	  
	def full_name
		[self.first_name, self.last_name].join(' ')
	end
end
