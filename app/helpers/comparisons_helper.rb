require 'open-uri'
module ComparisonsHelper
	INSERTPOINT = '/dp/'
	DELETEPOINT = '/ref='
	TECHDATA = '/dp/tech-data/'
	WEIGHT_DEFAULT = 1
	SCORE_DEFAULT = 0.5
	URL1 = 'http://www.amazon.com/Samsung-Galaxy-Tab-7-Inch-White/dp/B00D02AGU4/ref=sr_1_2?s=electronics&ie=UTF8&qid=1386353560&sr=1-2&keywords=tablet'
	URL2 = 'http://www.amazon.com/Google-Nexus-Tablet-7-Inch-Black/dp/B00DVFLJKQ/ref=sr_1_2?ie=UTF8&qid=1386612400&sr=8-2&keywords=7%22+tablet'
	#Allow these:
	#name: [weight, group, placement within group]
	TRIBUTES_ALLOWED = {
		Actor: [100,2,1],
		Artist: [10,2,26],
		AspectRatio: [1,2,27],
		AudienceRating: [1,3,41], 
		AudioFormat: [1,3,42],
		Author: [10,2,5],
		Brand: [10, 2,7],
		Color: [1,1,22],
		Creator:[1,3,43],
		Director: [10,1,6],
		Feature: [1,1,10],
		Format: [1,3,44],
		HardwarePlatform: [1,1,11],
		Genre: [1,2,28],
		IsAutographed: [10,1,23],
		Dimensions: [1,1,12],
		Languages: [1,2,29],
		price: [100,1,2],
		Manufacturer: [1,3,45],
		Model: [1,1,8],
		NumberOfItems: [1,1,17],
		NumberOfPages: [1,1,18],
		OperatingSystem: [1,1,9],
		PackageQuantity: [1,1,19],
		Platform: [1,2,34],
		PublicationDate: [1,2,35],
		ReleaseDate: [1,1,20],
		RunningTime: [1,1,21],
		Size: [1,2,36],
		SubscriptionLength: [1,2,37],
		Title: [1,1,1],
		Studio: [1,2,38],
		Warranty: [1,2,39]
	}

	TRIBUTES_DISALLOWED = [
		'Amazon.com Return Policy'
	]

	# main function to handle the entire back end => will move to controller
	def crunchm(comp, product, raw_link)
		parsed = parseAmazon(raw_link)
		# @tributes_hash = Hash.new
		nokogiriAmazon(@asin, comp, product, @tech_detail_link)
		# puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
		# puts products_hash
		# puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
		vacuumAmazon(@asin, product, comp)
		calculate_price_score
		calculate_amazon_rating_score
		calculate_crunchm_value
		# products_hash[@asin.to_sym] = vacuumAmazon(@asin, product, comp)
		# tributes_all_hash = build_tributes_all_hash(tributes_all_hash, products_hash)
		# products_hash[:tributes_all_hash] = sort_rows_by_placement_order(tributes_all_hash)
		# return products_hash
	end	

	def parseAmazon(raw_link)
		#parsed_array = raw_link.split(DELETEPOINT, 2)
		user_url_splitted = raw_link.gsub('/gp/', INSERTPOINT).split(INSERTPOINT, 2 )
		begin_url = user_url_splitted.first
		@asin = user_url_splitted.last.to_s[0..9]
		@parsed = [begin_url, TECHDATA, @asin].join("")
		# @parsed = parsed_array[0]
		# @asin = @parsed.split('/').last
		@tech_detail_link = @parsed
		puts "PARSED AMAZON" + @parsed
		puts "Tech detailed AMAZON" + @tech_detail_link
		puts "ASIN is ==============================" + @asin
	end
	
	# We're using NOKOGIRI to crowl tech detail page and bring attriutes not on item detail
	def nokogiriAmazon(asin, comp, product, parsed_url)
		# uses 'nokogiri' gem and 'open-uri'
		counter = 50 # we start at 50 to place these at the bottom of the attributes list 
		technical_detail = Nokogiri::HTML(open(parsed_url))
		
		# Amazon rating is not included in the item attributes, so we extract it separately
		customer_rating = retrieveRating(technical_detail)
		# tributes_hash[:AmazonRating]= { value: customer_rating,
		# 						weight: 100,
		# 						score: SCORE_DEFAULT,
		# 						group: 1,
		# 						placement: 0,
		# 						asin: asin
		# 						}
		tribute = Tribute.create(name: "Amazon Rating",
								value: customer_rating,
								weight: 100,
								score: SCORE_DEFAULT,
								group: 1,
								placement: 0,
								asin: asin)
		product.tributes.push(tribute) 
		comp.tributes.push(tribute)
	# puts technical_detail.css("#technical-data .bucket .content li")
		technical_detail.css("#technical-data .bucket .content li").each do |r| 
		#  r.class # is a Nokogiri::XML::Element
		#  technical_detail.class  # is a Nokogiri::HTML::Document
			technical_html = r.to_s
			# if Amazon included a title for the attribute in a <b> tag
			if technical_html.include?(':</b>') 
                key = technical_html.split("<b>").last.split(":</b>").first
				value = technical_html.split('</b> ').last.split('</li>').first
				unless TRIBUTES_DISALLOWED.include?(key)	
					tribute = Tribute.create(name: key,
						value: value,
						weight: WEIGHT_DEFAULT,
						score: SCORE_DEFAULT,
						group: 2,
						placement: counter,
						asin: asin) 					
					product.tributes.push(tribute) 
					comp.tributes.push(tribute)
				end
				# tributes_hash[key.to_sym] = { 	
				# 	name: key,
				# 	value: value,
				# 	weight: WEIGHT_DEFAULT,
				# 	score: SCORE_DEFAULT,
				# 	group: 2,
				# 	placement: counter,
				# 	asin: asin
				# 	}
				# tribute = tributes_hash[key.to_sym]
				puts tribute
				puts tribute.class
					
			# else # 'there is no title for the attribute on Amazon's site
			#will not display these features as vacuumAmazon will produce same features
				# tribute = { 'Feature':
				# 		value: technical_html.split('<li>').last.split('</li>').first,
				# 		weight: WEIGHT_DEFAULT,
				# 		score: SCORE_DEFAULT}		
			end
			# tributes_hash.push(tribute)  				
			counter += 1		
		end	
        # return tributes_names_hash

        # return tributes_hash
	end

	def retrieveRating(parsed_url)
 #<div id="averageCustomerReviews" class="a-spacing-small" data-asin="B007RVHDAK" data-ref="dp_top_cm_cr_acr_pop_">
    customer_rating = parsed_url.css("#handleBuy div span span span a span span").to_s[6..8].to_f
    # <span class="reviewCountTextLinkedHistogram" title="4.2 out of 5 stars">
    #     <a href="javascript:void(0)" class="a-popover-trigger a-declarative">
    #         <i class="a-icon a-icon-star a-star-4"></i>
    #     <i class="a-icon a-icon-popover"></i></a><span class="a-letter-space"></span>
    # </span>
	end	

	def vacuumAmazon(asin, product, comp)
		request = Vacuum.new
		request.configure(
		    aws_access_key_id:     'AKIAJOKI7B4MLG6KQW3Q',
		    aws_secret_access_key: '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',
		    associate_tag:         'crunchm-20'
		)
		params = {
		  'ItemId' => asin,
		  'ResponseGroup' => 'ItemAttributes,Images,OfferFull'
		}
		results = request.item_lookup(params)
		puts results.class
		puts '************************************************************************************'
		item_attributes = results.to_h
		tributes_vacuum_hash = item_attributes["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]
		
		img = item_attributes["ItemLookupResponse"]["Items"]["Item"]["MediumImage"]["URL"]

		if dimensions = item_attributes["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["ItemDimensions"]
			h = (dimensions["Height"]["__content__"].to_i) / 100
			l = (dimensions["Length"]["__content__"].to_i) / 100
			w = (dimensions["Width"]["__content__"].to_i) / 100

			if dimensions["Weight"]
				lb = ((dimensions["Weight"]["__content__"].to_i) / 100)
				lbs = 'lbs'
			else
				lb = 'N/A'
				lbs = ''
			end
			puts h, lb
			puts h.class


			dimensions = "W: #{w} in x L: #{l} in x H: #{h} in; Weight: #{lb} #{lbs}"

			puts dimensions
			puts 'dimension &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
			puts 'dimension &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
			puts 'dimension &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
			puts 'dimension &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
			puts 'dimension &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
			puts 'dimension &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
			puts 'dimension &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
			
			tribute = Tribute.create(name: :Dimensions,
					value: dimensions,
					weight: TRIBUTES_ALLOWED[:Dimensions][0],
					score: SCORE_DEFAULT,
					group: TRIBUTES_ALLOWED[:Dimensions][1],
					placement: TRIBUTES_ALLOWED[:Dimensions][2],
					asin: asin)
			product.tributes.push(tribute)
			comp.tributes.push(tribute)	 
		end

# {"Height"=>{"__content__"=>"712", "Units"=>"hundredths-inches"}, "Length"=>{"__content__"=>"1150", "Units"=>"hundredths-inches"}, "Weight"=>{"__content__"=>"800", "Units"=>"hundredths-pounds"}, "Width"=>{"__content__"=>"1350", "Units"=>"hundredths-inches"}}
		puts "item attributes hash is here &&&&&&&&&&&&&&&&&&&&&&&&&&&&"
		puts item_attributes
		# sale price is Amazon discounted price, but it is not always available
		if item_attributes["ItemLookupResponse"]["Items"]["Item"]["Offers"]["Offer"] && item_attributes["ItemLookupResponse"]["Items"]["Item"]["Offers"]["Offer"]["OfferListing"]["SalePrice"]
			puts 'does it get here? ******************************'
			price_hash = {
				price: item_attributes["ItemLookupResponse"]["Items"]["Item"]["Offers"]["Offer"]["OfferListing"]["SalePrice"]["FormattedPrice"],
				# price_data: item_attributes["ItemLookupResponse"]["Items"]["Item"]["Offers"]["Offer"]["OfferListing"]["SalePrice"]["Amount"]
			}
		elsif item_attributes["ItemLookupResponse"]["Items"]["Item"]["Offers"]["Offer"] && item_attributes["ItemLookupResponse"]["Items"]["Item"]["Offers"]["Offer"]["OfferListing"]["Price"]["FormattedPrice"]
			price_hash = {
				price: item_attributes["ItemLookupResponse"]["Items"]["Item"]["Offers"]["Offer"]["OfferListing"]["Price"]["FormattedPrice"],
				# price_data: item_attributes["ItemLookupResponse"]["Items"]["Item"]["Offers"]["Offer"]["OfferListing"]["Price"]["Amount"]
			}
		else
			price_hash = {
				price: 'oops... unavailable'
			}	
		end
		
		price_hash.each do |key, value|
			tribute = Tribute.create(name: 	key,
				value: value,
				weight: TRIBUTES_ALLOWED[key.to_sym][0],
				score: SCORE_DEFAULT,
				group: TRIBUTES_ALLOWED[key.to_sym][1],
				placement: TRIBUTES_ALLOWED[key.to_sym][2],
				asin: asin)
			product.tributes.push(tribute)
			comp.tributes.push(tribute)		
		end


		tribute = Tribute.create(name: "image", value: img, asin: asin )
		product.tributes.push(tribute)
		comp.tributes.push(tribute)
		
		tributes_vacuum_hash.each do |key, value| 
			if TRIBUTES_ALLOWED.has_key?(key.to_sym)
				# puts "the key is // " + key.to_s + 'and the value is ' + value.to_s
				# puts value, TRIBUTES_ALLOWED[key.to_sym][0], TRIBUTES_ALLOWED[key.to_sym][1], TRIBUTES_ALLOWED[key.to_sym][2]
				# puts key.class
				# tributes_hash[key.to_sym] = {
				# 		value: value,
				# 		weight: TRIBUTES_ALLOWED[key.to_sym][0],
				# 		score: SCORE_DEFAULT,
				# 		group: TRIBUTES_ALLOWED[key.to_sym][1],
				# 		placement: TRIBUTES_ALLOWED[key.to_sym][2],
				# 		asin: asin}
				tribute = Tribute.create(name: 	key,
						value: value.to_s,
						weight: TRIBUTES_ALLOWED[key.to_sym][0],
						score: SCORE_DEFAULT,
						group: TRIBUTES_ALLOWED[key.to_sym][1],
						placement: TRIBUTES_ALLOWED[key.to_sym][2],
						asin: asin)
				product.tributes.push(tribute) 
				comp.tributes.push(tribute)
				
			end
		end	
		# tributes_hash
	end	
	# def build_tributes_all_hash(tributes_all_hash, products_hash)
	# 	products_hash.each do |asin, details|
	# 		details.each do |name, values|
	# 			if values.is_a? Hash
	# 				tributes_all_hash[name.to_sym] = {weight: (values[:weight]), group: (values[:group]), placement: (values[:placement])}
	# 			end
	# 		end
	# 	end
	#  	tributes_all_hash	
	# end	

	def calculate_crunchm_value
		# algorithm to calculate ranking:
		# weight for each attribute has three options: 1, 10 or 100
		# value goes between 1 and 10 for each attribute-value
		# for price and amazon rating we calculate product's attribute value by deviding the lowest value by this product's value and timing the quatient by 10
		# we then add the weighted score
		comparison = current_comparison
		
		# calculate_price_score
		# calculate_amazon_rating_score
		
		comparison.products.each do |product|
			product.ranking = 0

			product.tributes.each do |tribute|
				product.ranking += ((tribute.score)*(tribute.weight)) if !tribute.score.nil?
			end
			product.save
		end		
	end	

	def calculate_price_score
		comparison = current_comparison
		# find the lowest price
		prices = []
		comparison.tributes.where(name: 'price').each do |tribute |
			prices << tribute.value[1..-1].to_f if tribute.value[0] == '$'
		end
		puts prices
		lowest_price = prices.min

		# score for price
		comparison.tributes.where(name: 'price').each do |tribute |

			puts "float should be here ##22222222222222222222222222222222222"
			puts tribute.value[1..-1].to_f

			if tribute.value[1..-1].to_f === lowest_price
				tribute.score = 1
			elsif !lowest_price.nil? && !tribute.value.nil?
				tribute.score = lowest_price / (tribute.value[1..-1].to_f)
			else
				tribute.score = 0
			end
		end

	end

	def calculate_amazon_rating_score
		comparison = current_comparison
		# find the lowest rating
		ratings = []
		comparison.tributes.where(name: 'customer_rating').each do |tribute |
			ratings << tribute.value if tribute.value > 0
		end
		lowest_rating = ratings.min

		# score for customer rating
		comparison.tributes.where(name: 'customer_rating').each do |tribute |
			if tribute.value == 0
				tribute.score = 0.5
			else
				tribute.score = lowest_rating / tribute.value
			end
		end
	end	

	def current_comparison
		if params[:comparison_id]
			@comparison = Comparison.find(params[:comparison_id])
		else
			@comparison = Comparison.find(params[:id])	
		end	
	end

	def current_product
		@product = Product.find(params[:product_id])
	end

	def create_table_hash(comparison)

		t = comparison.tributes.group("name").order("placement")
		puts ' &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'

		tributes_all_hash = Hash.new
		t.each do |x|
			tributes_all_hash[x.name.to_sym] = {weight: x.weight, placement: x.placement, group: x.group}
			
			if TRIBUTES_ALLOWED.has_key?(x.name.to_sym)
				puts "tribute name will go below"
				puts TRIBUTES_ALLOWED[x.name.to_sym][0]

					shared_tributes = SharedTribute.create(
															name: x.name.to_sym,
															weight: TRIBUTES_ALLOWED[x.name.to_sym][0],
														)
					
				comparison.shared_tributes.push(shared_tributes)
			end
			
			
			# puts x.weight
			# puts x.placement
		# products = Product.where(comparison_id: params[:id]).order('ranking DESC')
		# products = current_comparison.products.order('ranking DESC')
		
		# A.each{|x| puts x.ranking} # this could be something


		end
		asin_hash = comparison.tributes.group('asin')
		products_hash = Hash.new
		
		# puts ' &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&'
		# puts params[:id]
		asin_hash.each do |t|
			
			
			tribute_data = comparison.tributes.where( asin: t.asin )
			# puts tribute_data
			# puts '##############'
			products_hash[t.asin.to_sym] = Hash.new
			tribute_data.each do |x|
				
				products_hash[t.asin.to_sym][x.name] = {
						value: x.value,
						weight: x.weight,
						score: x.score,
						group: x.group,
						placement: x.placement
						}
			end
		end
		products_hash[:tributes_all_hash] = tributes_all_hash

		products_hash 

	end



	# def sort_rows_by_placement_order(tributes_all_hash)
	# 	sorted_hash = tributes_all_hash.sort_by { |tribute, values| values[:placement]}
	# end	

#Do NOT allow:
tributes_disallowed = %w(
	Binding # as: Product Category 
	Category
	CEROAgeRating
	ClothingSize
	Role
	Department
	EAN
	EANList
	EANListElement
	Edition
	EISBN
	EpisodeSequence
	ESRBAgeRating
	HazardousMaterialType
	IsAdultProduct
	ISBN
	IsEligibleForTradeIn
	IsMemorabilia
	IssuesPerYear
	ItemPartNumber
	Label
	LegalDisclaimer
	ManufacturerMaximumAge
	ManufacturerMinimumAge
	ManufacturerPartsWarrantyDescription
	MediaType
	MPN
	NumberOfDiscs
	NumberOfIssues
	NumberOfTracks
	PartNumber
	ProductGroup
	ProductTypeSubcategory
	Publisher
	RegionCode
	SeikodoProductCode
	SKU
	TradeInValue
	UPC
	UPCList
	UPCListElement
	WEEETaxValue)
end
