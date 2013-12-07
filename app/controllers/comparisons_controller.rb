class ComparisonsController < ApplicationController
	#If logged in -> show previous crunches
	def index
	end

	#Show form for new comparison (two inputs for urls and submit button)
	def new
		@comparison = Comparison.new

		2.times do 
			@comparison.products.build
		end

		# @product1 = Product.new
		# @product2 = Product.new
	end

	#Submit form and process, figure out the winning product
	def create
		puts "CREATEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
		puts params
		puts "CREATEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
		@comparison = Comparison.new(comparison_params)
		#we need to change this to if parsed, not if saved
		if @comparison.save
			params[:comparison][:products_attributes].each do |a|
				# this does something weird and gives the numerical key as a string instead of a key and "flattens" the hash.
				# this is why we have to do another loop to access the actual hash in there that has the url value.
				a.each do |b|
					if b.is_a? Hash
						# so b here is {:url => "google.com"} for instance.
						# we push because @comparison.products is an array
						@comparison.products.push(Product.create(url: b[:url]))
						
						# In the future version:
						crunchm(b[:url])
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
