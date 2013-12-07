class ProductsController < ApplicationController

	# ????delete index?????
	def index
		@comparison = Comparison.find(params[:id])
		@products = Product.where(comparison_id: params[:id])
	end

	# ????delete new?????
	def new
		@comparison = Comparison.new
		@product = Product.new
	end

	# add 3+ products
	def create
		# @comparison = Comparison.new(params[:url])
		# if @comparison.save
		# 	redirect_to comparisons_path
		# else redirect_to :back, :flash=> { errors: @comparison.errors.full_messages}
		# end
	end

	# price change, 
	def update
	end	

	# delete this product from the table
	def destroy
	end	

	private
	def parse_url

	end

	public
	def show
	end

	def edit
	end

	def update
	end

	def destroy
	end


end
