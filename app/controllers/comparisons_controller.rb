class ComparisonsController < ApplicationController
	#If logged in -> show previous crunches
	def index
		if signed_in?
			@user = current_user 
			if @user.comparisons.any?
				@comparisons = @user.comparisons		
				# redirect_to user_comparisons_path(@comparisons)
			else
				redirect_to new_user_comparison_path, notice: "There were no saved comparisons for #{@user.full_name}"
			end
		else #not logged in
			redirect_to new_comparison_path, notice: 'Login or register to save your crunchm'
		end
	end

	#form for new comparison (two inputs for urls and a submit button)
	def new
		@user = User.new
		@comparison = Comparison.new
		2.times do 
			@comparison.products.build
		end
	end

	#Submit form and process, figure out the winning product
	def create
        @comparison = Comparison.new(comparison_params)
   		@user = current_user
		#!!!!!!!!!!!!!!! note: we need to change this to if parsed, not if saved
		if @comparison.save
			session[:url_hash] = params[:comparison][:products_attributes]
	        redirect_to edit_comparison_path(@comparison)
		else
			puts @comparison.errors.full_messages
		end
		# @comparison = Comparison.new(params[:url])
		# if @comparison.save
		# 	redirect_to comparisons_path
		# else redirect_to :back, :flash=> { errors: @comparison.errors.full_messages}
		# end
        # redirect_to edit_comparison_path(@comparison)
		# render action: "edit"

	end

	#Show the table, display the winning product
	#this is the page to add/delete tributes/products (add product calls ProductsController create action)
	#change weight and scores. re-sort
	def edit
		# @product = Product.new
		puts params
        @comparison = Comparison.find(params[:id])
		# @products_hash = Hash.new
        # @tributes_all_hash = Hash.new
        @user = current_user
		@user.comparisons += [@comparison]
		# @product = Product.create(url: session[0][:url_hash][:url])
		# @product = Product.create(url: session[1][:url_hash][:url])
		puts 'showing the count below 888888888888888888888888888888888888888888888888'
		puts @comparison.products.count
		unless @comparison.products.count > 1
			session[:url_hash].each do |a|
				# because this returns the numerical key as a string instead of a key and "flattens" the hash
				# we loop to access the actual hash that has the url value.
				puts 'showing the session a below 888888888888888888888888888888888888888888888888'
				puts a
				a.each do |b|
					if b.is_a? Hash
						puts 'showing the session b below 888888888888888888888888888888888888888888888888'
						puts b
						# so b here is {:url => "google.com"} for instance.
						# we push because @comparison.products is an array
						@product = Product.create(url: b[:url])
						
						# crunchm!!!!!!!!!
						crunchm(@comparison, @product, b[:url])
						# puts "CRUNCHMCRUNCHMCRUNCHMCRUNCHMCRUNCHMCRUNCHMCRUNCHMCRUNCHMCRUNCHMCRUNCHM"
						# # puts @crunchm.keys
						# puts "CRUNCHMCRUNCHMCRUNCHMCRUNCHMCRUNCHMCRUNCHMCRUNCHMCRUNCHMCRUNCHMCRUNCHM"

						@comparison.products.push(@product)
						# @comparison.tributes.push()
						
						# parseAmazon (b[:url])
						# p = Product.create (url: b[:url], name: name_from_nokogiri)
						# tributes_from_nokogiri.each do |tribute|
						#  t = Tribute.create ( tribute attributes )
						#  p.tributes.push(t)
						# end
						
						# end

					end
				end	
			end
		else 
			session[:url_hash].each do |a|
				# because this returns the numerical key as a string instead of a key and "flattens" the hash
				# we loop to access the actual hash that has the url value.
				puts 'showing the session a below 888888888888888888888888888888888888888888888888'
				puts a
				a.each do |b|
					if b.is_a? Hash
						puts 'showing the session b below 888888888888888888888888888888888888888888888888'
						puts b
						@product = Product.new(url: b[:url])
						# so b here is {:url => "google.com"} for instance.
						# we push because @comparison.products is an array						
					end
				end
			end
		end	
		# @product = Product.new(url: 'just a placeholder for now')
		puts 'looks like it fails right here 888888888888888888888888888'
		@crunchm = create_table_hash(@comparison)
		puts 'looks like it fails right here 888888888888888888888888888'
		@products = current_comparison.products.all		
	end

	#process edits, recalculates winner
	def update
		@user = current_user
		@comparison = Comparison.find(params[:id])
		# @comparison.products.crunchm(@comparison, product, raw_link, products_hash, tributes_all_hash)
		redirect_to comparison_path
	end

	#if logged in - delete table
	def destroy
	end

	private
	def parse_url

	end

	def comparison_params
		params.require(:comparison).permit(:name, :note, :products_attributes, :user_id)
	end

end