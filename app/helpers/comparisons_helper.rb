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
		#CSS-ARRAY=['#productDetails', '#priceblock_ourprice', '#technical-data' ]

		# uses 'nokogiri' gem and 'open-uri'

		# a page that has technical details:
		# tech = Nokogiri::HTML(open('http://www.amazon.com/MeMOPad-HD-7-Inch-Blue-ME173X-A1-BL/dp/tech-data/B00E0EY7Z6/ref=de_a_smtd'))
		#.css('#productDetails').each
		# tech.css(".bucket .content li").each {|r| puts r}

		puts "parsed url"
		puts parsed_url
		puts "class"
		puts parsed_url.class

		technical_detail = Nokogiri::HTML(open(parsed_url))
		#works:
		#technical_detail.css("h1").each { |d| puts d.content }
		#technical_detail.css("#technical-data .bucket .content li").each {|r| puts r}
		technical_detail.css("#technical-data .bucket .content li").each do |r| 
			# puts r
			# puts r.class # is a Nokogiri::XML::Element
			# puts technical_detail.class  # is a Nokogiri::HTML::Document
			# puts r.('b').xpath.inner_text + 'is a b element'
			technical_html = r.to_s
			# puts technical_html
			if technical_html.include?(':</b>')
				# @comparison.products.push(Product.create(url: b[:url]))
				@comparison.products.tributes.push(Tribute.create(name: technical_html.split("<b>").last.split(":</b>").first,
																value: technical_html.split('</b> ').last.split('</li>').first,
																weight: WEIGHT_DEFAULT,
																score: SCORE_DEFAULT))
			else
				@tribute = 'Feauture'
				@value = technical_html.split('<li>').last.split('</li>').first
				"NO TRIBUTE!!!!!!!!!!!!!!!!!!!!!!!!" + technical_html	
				
			end
			puts "TRIBUTE IS: "+@tribute
			puts "VALUE IS: " +@value				
			
			# if r.css('li b') 
			# 	puts "the attribute is" + r 
			# else
			# 	puts 'the valueeeeeeeeeeee'	+ r  
			# end		
		end	
	end
end
# http://www.amazon.com/Samsung-Galaxy-Tab-7-Inch-White/dp/B00D02AGU4/ref=sr_1_2?s=electronics&ie=UTF8&qid=1386353560&sr=1-2&keywords=tablet