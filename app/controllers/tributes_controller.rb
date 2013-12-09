class TributesController < ApplicationController
	# add custom tributes
	def create
		@create = Create.new
	end

	# update score or weight 
	def update
	end	

	# delete this tribute from the table
	def destroy
	end	

end
