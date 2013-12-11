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
		ItemDimensions: [1,1,12],
		Languages: [1,2,29],
		ListPrice: [100,1,2],
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

	# main function to handle the entire back end => will move to controller
	def crunchm(comp, product, raw_link, products_hash, tributes_all_hash)
		parsed = parseAmazon(raw_link)
		@tributes_hash = Hash.new
		nokogiri_amazon = nokogiriAmazon(@asin, comp, product, @tech_detail_link, @tributes_hash)
		puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'
		puts products_hash
		puts '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~'

		products_hash[@asin.to_sym] = vacuumAmazon(@asin, nokogiri_amazon)
		tributes_all_hash = build_tributes_all_hash(tributes_all_hash, products_hash)
		products_hash[:tributes_all_hash] = sort_rows_by_placement_order(tributes_all_hash)

		return products_hash
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
	
	# NOKOGIRI STUFF GOES HERE
	def nokogiriAmazon(asin, comp, product, parsed_url, tributes_hash)
		# uses 'nokogiri' gem and 'open-uri'
		counter = 0
		technical_detail = Nokogiri::HTML(open(parsed_url))
		# Amazon rating is not included in the item attributes, so we extract it separately
		customer_rating = retrieveRating(technical_detail)
		tributes_hash[:AmazonRating]= { value: customer_rating,
								weight: 100,
								score: SCORE_DEFAULT,
								group: 1,
								placement: 0,
								asin: asin
								}
	puts '++++====================================++++'
	puts customer_rating
	puts '++++====================================++++'
		technical_detail.css("#technical-data .bucket .content li").each do |r| 
		#  r.class # is a Nokogiri::XML::Element
		#  technical_detail.class  # is a Nokogiri::HTML::Document
			technical_html = r.to_s
			

			# if Amazon included a title for the attribute in a <b> tag
			if technical_html.include?(':</b>')
                key = technical_html.split("<b>").last.split(":</b>").first
				value = technical_html.split('</b> ').last.split('</li>').first
				# tributes_names_hash[name] = WEIGHT_DEFAULT
				puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
				tributes_hash[key.to_sym]= { value: value,
								weight: WEIGHT_DEFAULT,
								score: SCORE_DEFAULT,
								group: 2,
								placement: counter,
								asin: asin
								}
			
					
			# else # 'there is no title for the attribute on Amazon's site
			#will not display these features as vacuumAmazon will produce same features
				# tribute = { 'Feature':
				# 		value: technical_html.split('<li>').last.split('</li>').first,
				# 		weight: WEIGHT_DEFAULT,
				# 		score: SCORE_DEFAULT}
			end
			# tributes_hash.push(tribute)  NEED TO UNCOMMENT FOR DATABASE INPUT!!!!
			# product.tributes.push(tribute)  NEED TO UNCOMMENT FOR DATABASE INPUT!!!!
			# comp.tributes.push(tribute)	NEED TO UNCOMMENT FOR DATABASE INPUT!!!!
			counter += 1		
		end	
        # return tributes_names_hash
			puts ' ******* Nokogiri  - tributes hash*****************************'

        			puts tributes_hash
			puts ' ******* Nokogiri  - tributes hash*****************************'

        return tributes_hash
	end

# this is the same as above but it retrieves the data from db rather than from memory
 #    def make_first_column(comparison)
	# 	@tributes_names_hash = Hash.new
	# 	@comparison.tributes.each do |x| 
	# 		@tributes_names_hash[x.name] = WEIGHT_DEFAULT
	# 	end
	# 	return @tributes_names_hash
	# end

	def retrieveRating(parsed_url)
 #<div id="averageCustomerReviews" class="a-spacing-small" data-asin="B007RVHDAK" data-ref="dp_top_cm_cr_acr_pop_">
    customer_rating = parsed_url.css("#handleBuy div span span span a span span").to_s[6..8].to_f
    

    # <span class="reviewCountTextLinkedHistogram" title="4.2 out of 5 stars">
    #     <a href="javascript:void(0)" class="a-popover-trigger a-declarative">
    #         <i class="a-icon a-icon-star a-star-4"></i>
    #     <i class="a-icon a-icon-popover"></i></a><span class="a-letter-space"></span>
    # </span>
	end	

	def vacuumAmazon(asin, tributes_hash)
		request = Vacuum.new
		request.configure(
		    aws_access_key_id:     'AKIAJOKI7B4MLG6KQW3Q',
		    aws_secret_access_key: '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',
		    associate_tag:         'crunchm-20'
		)
		params = {
		  'ItemId' => asin,
		  'ResponseGroup' => 'ItemAttributes,Images'
		}
		results = request.item_lookup(params)
		puts results.class
		puts '************************************************************************************'
		item_attributes = results.to_h
		puts item_attributes.class
		# puts item_attributes
		puts item_attributes["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]
		# puts 'the brand is ' + item_attributes["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]["Brand"]
		tributes_vacuum_hash = item_attributes["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]
		img = item_attributes["ItemLookupResponse"]["Items"]["Item"]["LargeImage"]["URL"]
		tributes_hash[:image_url] = img
		tributes_vacuum_hash.each do |key, value| 
			if TRIBUTES_ALLOWED.has_key?(key.to_sym)
				puts "the key is // " + key.to_s + 'and the value is ' + value.to_s
				puts value, TRIBUTES_ALLOWED[key.to_sym][0], TRIBUTES_ALLOWED[key.to_sym][1], TRIBUTES_ALLOWED[key.to_sym][2]
				puts key.class
				tributes_hash[key.to_sym] = {
						value: value,
						weight: TRIBUTES_ALLOWED[key.to_sym][0],
						score: SCORE_DEFAULT,
						group: TRIBUTES_ALLOWED[key.to_sym][1],
						placement: TRIBUTES_ALLOWED[key.to_sym][2],
						asin: asin}
				
				# @tributes.push(@tribute)
				# tributes_hash << tribute
			end
		end	
		tributes_hash
	end	

	def build_tributes_all_hash(tributes_all_hash, products_hash)
		products_hash.each do |asin, details|
			details.each do |name, values|
				if values.is_a? Hash
					puts 'details.each name344***********J*****'
					puts name
					puts values
					puts values[:weight]
					puts tributes_all_hash
					tributes_all_hash[name.to_sym] = {weight: (values[:weight]), group: (values[:group]), placement: (values[:placement])}
				end
			end
		end
	 	tributes_all_hash	
	end	


	def current_comparison
		@comparison = Comparison.find(params[:comparison_id])
	end

	def current_product
		@product = Product.find(params[:product_id])
	end

	def sort_rows_by_placement_order(tributes_all_hash)
		sorted_hash = tributes_all_hash.sort_by { |tribute, values| values[:placement]}
		sorted_hash = sorted_hash.sort_by { |tribute, values| values[:group]}
	end	

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
