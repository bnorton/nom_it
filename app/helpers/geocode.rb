require 'ostruct'
REGIONS = ['austin','berkeley','boston','chicago','dc','denver','losangeles',
           'newyork','paloalto','portland','sacramento','sandiego','sanjose',
           'sanfrancisco','seattle','vegas']
BASE_DIR = './data/yelp'
DELIM = /<\^&/

class Geocode
  class << self
    
    def current_regions
      Geocode.scan_regions(['austin','portland'])
    end
    
    # write each region to its own file
    def scan_regions(regions=[])
      regions_to_scan = regions || REGIONS
      regions_to_scan.each do |region|
        @@path = "#{BASE_DIR}/#{region}"
        these_locations = process_directory(@@path)
        out = "#{@@path}/out/#{Time.now.strftime("%Y|%m|%d|%H|%M|%S_")}#{region}.txt"
        begin 
          File.open(out, 'w+') { |f| 
            f.write(these_locations.to_json)
          }
        rescue Exception
        rescue => e
        end
      end
    end
    
    def process_directory(path_to)
      locations = []
      Dir.foreach(path_to) do |file_name|
        unless ['.','..','out'].include? file_name
          puts "#{path_to} #{file_name}"
          File.open("#{@@path}/#{file_name}") do |file|
            process_file_into!(file, locations, file_name)
          end
        end
      end
      locations
    end
    
    def process_file_into!(file, locations, file_name)
      while true
        item = build_item(file)
        if (location = build_and_store_location(item,file_name))
          locations << location
        else
          break
        end
      end
    end
    # return a string of feature1\nfeature2\n
    def build_item(file)
      item = ""
      begin
        while true
          line = file.gets         # happens at the end
          unless line =~ /^[=]+$/ || line.nil?
            item << line
          else
            break
          end
        end
        item.gsub(/\n/,'<^&')
      rescue Exception => e
        puts "Exception"
        puts file.inspect
        puts item.inspect
        puts e.message
      rescue Errno::EISDIR => e
        puts "Errno::EISDIR"
        puts file.inspect
        puts item.inspect
        puts e.message
      rescue => e
        puts "e"
        puts file.inspect
        puts item.inspect
        puts e.message
      end
    end
    
    def fetch_yahoo_data(addr)
      begin
        if (yahoo_raw = Util.geocode_address(addr))
          result = yahoo_raw['ResultSet']['Result']
          if result.is_a? Array
            result = result[0]
          end
          return OpenStruct.new(result) unless result.blank?
          OpenStruct.new({})
        end
      rescue Exception
        puts "YAHOO for #{addr} FAILED #{yahoo_raw.inspect}"
        OpenStruct.new({})
      end
    end
    
    def yahoo_addr_neighbor(yahoo)
      line2 = yahoo.line2.try(:gsub,'  ', ' ')
      addr = "#{yahoo.line1} #{line2}" if line2
      addr ||= "#{yahoo.line1}" if yahoo.line1
      
      neighborhoods = yahoo.neighborhood.try(:gsub, '|', ' | ')
      
      street = "#{yahoo.house} #{yahoo.street}" if yahoo.house
      street ||= yahoo.street
      
      [addr,neighborhoods,street]
    end
    
    def yahoo_cross_street(yahoo)
      cross = yahoo.cross
      cross.gsub('the intersection of ','') if cross
    end
    
    def store_location(yahoo,opt={})
      iid = Util.ID
      addr,neigh,street = yahoo_addr_neighbor(yahoo)
      if (found = Location.find_by_location_hash(opt[:location_hash]))
        [found.nid, false]
      else
        Location.find_or_create_by_location_hash(
          :location_hash => opt[:location_hash],
          :name => opt[:name],
          :address => addr,
          :street => street,
          :cross_street => yahoo_cross_street(yahoo),
          :city => yahoo.city,
          :state => yahoo.state,
          :area_code => yahoo.postal,
          :country => yahoo.country,
          :primary => opt[:primary],
          :secondary => opt[:secondary],
          :neighborhoods => neigh,
          :cost => opt[:cost],
          :phone => opt[:phone],
          :timeofday => opt[:tod],
          :woeid => yahoo.woeid,
          :yid => yahoo.hash,
          :nid => iid)
        [iid, true]
      end
    end
    
    def store_geolocation(yahoo,opt={})
      Geolocation.find_or_create_by_location_nid(
        :location_nid => opt[:location_nid],
        :lat => yahoo.latitude,
        :lng => yahoo.longitude,
        :primary => opt[:primary],
        :secondary => opt[:secondary],
        :cost => opt[:cost]
      )
    end
    
    def store_metadata(opt={})
      if Metadata.create(opt[:nid])
        Metadata.set_yelp_items(opt)
      else
        raise "Metadata not created for #{opt.inspect}"
      end
    end
    
    def build_and_store_location(item,file_name)
      return false if item.blank?
      
      _address = address(item)
      yahoo = fetch_yahoo_data(_address)
      
      _name = name(item)
      location_hash = Digest::SHA2.hexdigest(_name + _address)
      
      _tod = timeofday(file_name)
      _cost = cost(file_name)
      _rating = rating(item)
      _rating_count = rating_count(item)
      _digits = digits(item)
      
      cats = categories(item)
      top_level_nid, category_nids = Category.new_categories('eat',cats,:assoc)
      
      primary = top_level_nid
      secondary = category_nids[0] rescue nil
      
      location_nid,is_new = store_location(yahoo,{
        :location_hash=>location_hash,
        :primary => primary,
        :secondary => secondary,
        :name => _name,
        :tod => _tod,
        :cost => _cost,
        :phone => _digits
      })
      if is_new
        store_geolocation(yahoo,{
          :location_nid => location_nid,
          :primary => primary,
          :secondary => secondary,
          :cost => _cost
        })
        
        Category.normalize!(cats)
        store_metadata({
          :nid => location_nid,
          :yelp_rating => _rating,
          :yelp_count => _rating_count,
          :categories => cats
          })
      end
      cats_str = cats.join(', ') rescue nil
      {
        :name => _name,
        :primary => primary,
        :secondary => secondary,
        :categories => cats_str,
        :neighborhood => neighborhood(item),
        :rating => _rating,
        :rating_count => _rating_count,
        :address => _address,
        :digits => _digits,
        :timeofday => _tod,
        :cost => _cost
      }
    end
    
    def name(item) # 1. SF Grill
      return $1 if item =~ /[0-9]+\.[ ]+([^<]+)<\^&/
    end
    
    def categories(item) # Categories: Farmers Market, Food Stands   ||   Category: Sandwiches
      return $1.split(', ') if item =~ /Categories\:[ ]+([^<]+)<\^&/
      $1.split(', ') if item =~ /Category\:[ ]+([^<]+)<\^&/
    end
    
    def neighborhood(item) # Neighborhood: Western Addition/NOPA
      return $1 if item =~ /Neighborhood\:[ ]+([^<]+)<\^&/
    end
    
    def rating(item) # 4.5 star rating
      return $1.to_f if item =~ /([1-5](\.?[05]))[ ]+star rating/
      0.0
    end
    
    def rating_count(item) # 34 reviews
      return $1.to_i if item =~ /([0-9]+)[ ]+reviews/
      0
    end
    
    def address(item) # Grove and Divisadero St
                      # San Francisco, CA 94117
      return "#{$1} #{$2}" if item =~ /reviews?<\^&([^<]+)<\^&([^<]+)<\^&/
      return "#{$1}" if item =~ /reviews?<\^&([^<]+)<\^&/
    end
    
    def digits(item) # (415) 235-4022
      return "#{$1}-#{$2}" if item =~ /\(([0-9]+)\)[ ]+([0-9\-]+)/
    end
    
    def timeofday(file_name) # filenames are ($)+_?[(breakfast)|(dessert)]?\.txt
      return 'breakfast | brunch'  if file_name =~ /(breakfast)/
      return 'dessert | latenight' if file_name =~ /(dessert)/
      'lunch | dinner'
    end
    
    # "$.txt" => $
    # "$$$.txt" => $$$
    # "$$_dessert.txt" => $$ 
    # "$_breakfast.txt" => $
    def cost(file_name)  # filenames are ($)+_?[(breakfast)|(dessert)]?\.txt
      return $1 if file_name =~ /(\$+)/
    end
  end
end

# Geocode.scan_regions(regions=['sanfrancisco'])

###############################################################################
#####   YELP EXTRACT   ########################################################
###############################################################################

## serialized '1. SF Grill<^&Categories: Farmers Market, Food Stands<^&Neighborhood: Western Addition/NOPA<^&4.5 star rating<^&34 reviews<^&Grove and Divisadero St<^&San Francisco, CA 94117<^&(415) 235-4022<^&=========='


# 1. SF Grill
# Categories: Farmers Market, Food Stands
# Neighborhood: Western Addition/NOPA
# 4.5 star rating
# 34 reviews
# Grove and Divisadero St
# San Francisco, CA 94117
# (415) 235-4022
# ==========
# 2. The Codmother Fish and Chips
# Categories: British, Fish & Chips, Seafood
# Neighborhood: Fisherman's Wharf
# 4.5 star rating
# 98 reviews
# 2824 Jones St
# San Francisco, CA 94133
# (415) 606-9349
# ==========
# 3. Gorilla Pete's Hot Dogs
# Categories: Hot Dogs, Caterers, Food Stands
# Neighborhood: SOMA
# 4.5 star rating
# 31 reviews
# Folsom St
# San Francisco, CA 94105
# (415) 793-0105
# ==========
# 4. M & L Market
# Category: Sandwiches
# Neighborhood: Castro
# 4.5 star rating
# 170 reviews
# 691 14th St
# San Francisco, CA 94114
# (415) 431-7044
# ==========


###############################################################################
#####   YAHOO RESULTS   #######################################################
###############################################################################
# http://where.yahooapis.com/geocode?q=795+Folsom+St+San+Francisco,+CA+94107&appid=QZb4Sj5i&flags=j
# {
#     "ResultSet": {
#         "version": "1.0",
#         "Error": 0,
#         "ErrorMessage": "No error",
#         "Locale": "us_US",
#         "Quality": 87,
#         "Found": 1,
#         "Results": [
#             {
#                 "quality": 87,
#                 "latitude": "37.782274",
#                 "longitude": "-122.400846",
#                 "offsetlat": "37.782186",
#                 "offsetlon": "-122.400734",
#                 "radius": 500,
#                 "name": "",
#                 "line1": "795 Folsom St",
#                 "line2": "San Francisco, CA 94107-1243",
#                 "line3": "",
#                 "line4": "United States",
#                 "house": "795",
#                 "street": "Folsom St",
#                 "xstreet": "",
#                 "unittype": "",
#                 "unit": "",
#                 "postal": "94107-1243",
#                 "neighborhood": "",
#                 "city": "San Francisco",
#                 "county": "San Francisco County",
#                 "state": "California",
#                 "country": "United States",
#                 "countrycode": "US",
#                 "statecode": "CA",
#                 "countycode": "",
#                 "uzip": "94107",
#                 "hash": "7C1347CA8B584A94",
#                 "woeid": 12797158,
#                 "woetype": 11
#             }
#         ]
#     }
# }

# {"ResultSet" =>
#     {
#        "version"=>"1.0",
#        "Error"=>"0",
#        "ErrorMessage"=>"No error",
#        "Locale"=>"us_US",
#        "Quality"=>"87",
#        "Found"=>"1",
#        "Result"=>
#           {
#             "quality"=>"87",
#              "latitude"=>"37.798666",
#              "longitude"=>"-122.407158",
#              "offsetlat"=>"37.798673",
#              "offsetlon"=>"-122.407033",
#              "radius"=>"500",
#              "name"=>nil,
#              "line1"=>"1268 Grant Ave",
#              "line2"=>"San Francisco, CA  94133-3914",
#              "line3"=>nil,
#              "line4"=>"United States",
#              "cross"=>"Between Vallejo St and Fresno St",
#              "house"=>"1268",
#              "street"=>"Grant Ave",
#              "xstreet"=>nil,
#              "unittype"=>nil,
#              "unit"=>nil,
#              "postal"=>"94133-3914",
#              "neighborhood"=>"Telegraph Hill",
#              "city"=>"San Francisco",
#              "county"=>"San Francisco County",
#              "state"=>"California",
#              "country"=>"United States",
#              "countrycode"=>"US",
#              "statecode"=>"CA",
#              "countycode"=>nil,
#              "uzip"=>"94133",
#              "hash"=>"ADA0728811437B1A",
#              "woeid"=>"12797183",
#              "woetype"=>"11"
#            }
#         }
#      }
