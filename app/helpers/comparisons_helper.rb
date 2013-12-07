require 'open-uri'
module ComparisonsHelper
	INSERTPOINT = '/dp/'
	DELETEPOINT = '/ref='
	TECHDATA = '/dp/tech-data/'
	WEIGHT_DEFAULT = 1
	SCORE_DEFAULT = 0.5
	# NOKOGIRI STUFF GOES HERE
	def crunchm(raw_link)
		parsed = parseAmazon(raw_link)
		nokogiriAmazon(@tech_detail_link)
		
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

	def nokogiriAmazon(parsed_url)
		# uses 'nokogiri' gem and 'open-uri'

		#CSS-ARRAY=['#productDetails', '#priceblock_ourprice', '#technical-data' ]
		technical_detail = Nokogiri::HTML(open(parsed_url))
		technical_detail.css("#technical-data .bucket .content li").each do |r| 
		#  r.class # is a Nokogiri::XML::Element
		#  technical_detail.class  # is a Nokogiri::HTML::Document
		technical_html = r.to_s
		if technical_html.include?(':</b>')
			@comparison.products.tributes.push(Tribute.create(name: technical_html.split("<b>").last.split(":</b>").first,
															value: technical_html.split('</b> ').last.split('</li>').first,
															weight: WEIGHT_DEFAULT,
															score: SCORE_DEFAULT))
		else
			@tribute = 'Feauture'
			@value = technical_html.split('<li>').last.split('</li>').first
			"NO TRIBUTE!!!!!!!!!!!!!!!!!!!!!!!!" + technical_html
		end
		# puts "TRIBUTE IS: "+@tribute
		# puts "VALUE IS: " +@value				
	end	
	end
end
# http://www.amazon.com/Samsung-Galaxy-Tab-7-Inch-White/dp/B00D02AGU4/ref=sr_1_2?s=electronics&ie=UTF8&qid=1386353560&sr=1-2&keywords=tablet