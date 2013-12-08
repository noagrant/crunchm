class ComparisonsController < ApplicationController
	#If logged in -> show previous crunches
	def index
		if signed_in?
			@user = current_user 
			if @user.comparisons.any?
				@comparisons = @user.comparisons		
				redirect_to user_comparisons_path(@comparisons)
			else
				redirect_to new_user_comparison_path, notice: 'There were no saved comparisons for #{@user.full_name}'
			end
		else #not logged in
			redirect_to new_comparison_path, notice: 'Login or register to save your crunchm'
		end
	end

	#form for new comparison (two inputs for urls and a submit button)
	def new
		@comparison = Comparison.new
		2.times do 
			@comparison.products.build
		end
	end

	#Submit form and process, figure out the winning product
	def create
		@comparison = Comparison.new(comparison_params)
		#!!!!!!!!!!!!!!! note: we need to change this to if parsed, not if saved
		if @comparison.save
			params[:comparison][:products_attributes].each do |a|
				# because this returns the numerical key as a string instead of a key and "flattens" the hash
				# we loop to access the actual hash that has the url value.
				a.each do |b|
					if b.is_a? Hash
						# so b here is {:url => "google.com"} for instance.
						# we push because @comparison.products is an array
						@product = Product.create(url: b[:url])
						
						# In the future version:
						crunchm(@comparison, @product, b[:url])
						@comparison.products.push(@product)
						@comparison.tributes.push()
						
						# parseAmazon (b[:url])
						# p = Product.create (url: b[:url], name: name_from_nokogiri)
						# tributes_from_nokogiri.each do |tribute|
						#  t = Tribute.create ( tribute attributes )
						#  p.tributes.push(t)
						# end
					end	
				end
			end
			puts "SUCCESS"
		else
			puts @comparison.errors.full_messages
		end
		# @comparison = Comparison.new(params[:url])
		# if @comparison.save
		# 	redirect_to comparisons_path
		# else redirect_to :back, :flash=> { errors: @comparison.errors.full_messages}
		# end

	end

	#Show the table, display the winning product
	#this is the page to add/delete tributes/products (add product calls ProductsController create action)
	#change weight and scores. re-sort
	def edit
	end

	#process edits, recalculates winner
	def update
	end

	#if logged in - delete table
	def destroy
	end

	private
	def parse_url

	end

	def comparison_params
		params.require(:comparison).permit(:name, :note, :products_attributes)
	end

end
