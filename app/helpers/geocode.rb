require 'ostruct'
REGIONS = ['austin','berkeley','boston','chicago','dc','denver','losangeles',
           'newyork','paloalto','portland','sacramento','sandiego','sanjose',
           'sanfrancisco','seattle','vegas'].uniq
BASE_DIR = '../../data/yelp'
DELIM = /<\^&/

class Geocode
  class << self
    
    # write each region to its own file
    def scan_regions(regions=[])
      regions_to_scan = regions || REGIONS
      regions_to_scan.each do |region|
        path = "#{BASE_DIR}/#{region}"
        these_locations = process_directory(path)
        out = "#{path}/out/#{Time.now.strftime("%Y|%m|%d|%H|%M|%S_")}#{region}.txt"
        File.open(out, 'w') { |f| 
          f.write(these_locations.to_json)
        }
      end
    end
    
    def process_directory(path_to)
      locations = []
      Dir.foreach(path_to) do |file_name|
        File.open(file_name) do |file|
          process_file_into!(file, locations, file_name)
        end
      end
      locations
    end
    
    def process_file_into!(file, locations, file_name)
      while true
        item = build_item(file)
        cats = categories(item)
        if (location = build_and_store_location(item,cats,file_name))
          locations << location
        else
          break
        end
      end
    end
    # return a string of feature1\nfeature2\n
    def build_item(file)
      item = ""
      while true
        line = file.gets
        unless line =~ /^[=]+$/
          item << line
        else
          break
        end
      end
      item.gsub('\n', DELIM)
    end
    
    def fetch_yahoo_data(addr)
      OpenStruct.new(Util.geocode_address(addr))
    end
    
    def store_location(yahoo,opt={})
      loc = Location.find_or_create_by_hash(opt[:hash])
      if loc.new_record?
        loc.name = opt[:_name]
        loc.address = "#{yahoo.line1} #{yahoo.line2}" if yahoo.line2
        loc.address ||= "#{yahoo.line1}"
        loc.street = "#{yahoo.house} #{yahoo.street}"
        loc.cross_street = yahoo.cross
        loc.city = yahoo.city
        loc.state = yahoo.state
        loc.area_code = yahoo.uzip
        loc.country = yahoo.country
        loc.primary = opt[:c0]
        loc.secordary = opt[:c1]
        loc.neighborhoods = yahoo.neighborhood
        loc.cost = opt[:cost]
        loc.timeofday = opt[:tod]
        loc.nid = Util.ID
        loc.save
      end
      loc.id
    end
    
    def store_geolocation(yahoo,opt={})
      Geolocation.find_or_create_by_location_id(
        :location_id => opt[:location_id],
        :lat => yahoo.latitude,
        :lng => yahoo.longitude
      )
    end
    
    def store_metadata(opt={})
      Metadata.find_or_create_by_location_id({
        :location_id => opt[:location_id],
        :yelp_rating => opt[:yelp_rating],
        :yelp_rating_count => opt[:yelp_rating_count]
        })
    end
    
    def build_and_store_location(item,cats,file_name)
      return false if item.blank?
      c0 = cats[0] rescue nil
      c1 = cats[1] rescue nil
      
      Category.new_categories('eat',cats)
      
      _address = address(item)
      yahoo = fetch_yahoo_data(_address)
      
      _name = name(item)
      hash = Digest::SHA2.hexdigest(_name + _address)
      
      _tod = timeofday(file_name)
      _cost = cost(file_name)
      _rating = rating(item)
      _rating_count = rating_count(item)
      _digits = digits(item)
      
      location_id = store_location(yahoo,{
        :hash=>hash,
        :c0=>c1,
        :c1=>c1,
        :_name=>_name,
        :tod => _tod,
        :cost => _cost
      })
      
      store_geolocation(yahoo,{
        :location_id => location_id
      })
      
      store_metadata(yahoo,{
        :location_id => location_id
        
      })
      
      {
        :name => _name,
        :primary => c0,
        :secondary => c1,
        :categories => cats.join(', '),
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
      return 'breakfast|brunch'  if file_name =~ /(breakfast)/
      return 'dessert|latenight' if file_name =~ /(dessert)/
      'lunch|dinner'
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
      