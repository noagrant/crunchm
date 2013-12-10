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
	#[weight, group, placement within group]
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

	# NOKOGIRI STUFF GOES HERE
	def crunchm(comp, product, raw_link, tributes_names_hash)
		parsed = parseAmazon(raw_link)
		# @tributes = Tribute.new
		return nokogiriAmazon(comp, product, @tech_detail_link, tributes_names_hash)
		vacuumAmazon(@asin)
	end	

	def parseAmazon(raw_link)
		parsed_array = raw_link.split(DELETEPOINT, 2)
		@parsed = parsed_array[0]
		@asin = @parsed.split('/').last
		@tech_detail_link = @parsed.gsub(INSERTPOINT,TECHDATA)
		puts "PARSED AMAZON" + @parsed
		puts "Tech detailed AMAZON" + @tech_detail_link
		puts "ASIN is ==============================" + @asin
	end

	def nokogiriAmazon(comp, product, parsed_url, tributes_names_hash)
		# uses 'nokogiri' gem and 'open-uri'

		technical_detail = Nokogiri::HTML(open(parsed_url))
		technical_detail.css("#technical-data .bucket .content li").each do |r| 
		#  r.class # is a Nokogiri::XML::Element
		#  technical_detail.class  # is a Nokogiri::HTML::Document
			technical_html = r.to_s
			
			# if Amazon included a title for the attribute in a <b> tag
			if technical_html.include?(':</b>')
                name = technical_html.split("<b>").last.split(":</b>").first
				value = technical_html.split('</b> ').last.split('</li>').first
				tributes_names_hash[name] = WEIGHT_DEFAULT

				tribute = {name: name,
						value: value,
						weight: WEIGHT_DEFAULT,
						score: SCORE_DEFAULT}
				
			else # 'there is no title for the attribute on Amazon's site
				tribute = {name: 'Feature',
						value: technical_html.split('<li>').last.split('</li>').first,
						weight: WEIGHT_DEFAULT,
						score: SCORE_DEFAULT}
			end
			@@tributes.push(tribute)
			product.tributes.push(tribute)
			comp.tributes.push(tribute)			
		end	
        return tributes_names_hash
	end

# this is the same as above but it retrieves the data from db rather than from memory
 #    def make_first_column(comparison)
	# 	@tributes_names_hash = Hash.new
	# 	@comparison.tributes.each do |x| 
	# 		@tributes_names_hash[x.name] = WEIGHT_DEFAULT
	# 	end
	# 	return @tributes_names_hash
	# end

	def vacuumAmazon(asin)
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
		tributes_hash = item_attributes["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]
		
		tributes_hash.each do |key, value| 
			if TRIBUTES_ALLOWED.has_key?(key.to_sym)
				puts "the key is // " + key.to_s + 'and the value is ' + value.to_s
				Tribute.new = {name: key,
						value: value,
						weight: WEIGHT_DEFAULT,
						score: SCORE_DEFAULT}
				# @tributes.push(@tribute)

			end
		end	
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
