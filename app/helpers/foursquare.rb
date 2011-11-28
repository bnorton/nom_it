require "net/http"
require "uri"

class Foursquare
  class << self

    def fetch
      pre_process
      process
      post_process
    end

    def uri
       @uri ||= URI.parse('https://api.foursquare.com/v2/venues/search')
     end

    private

    def params
      {
        :client_id => 'MMTDRELAR4YGYAPTTO2RU45PMI3YY2JGAJRXU300MPC3KNGI',
        :client_secret => 'BMBDVSF4XXBTZ0AISFSQPON2XUA41CDLVLFQRCT0KXQBO3U2',
        :v => '20110831',
        :intent => 'match',
        :limit => 1
      }
    end

    def pre_process
      @offset = 0
      @locations = Foursquare.send(:next)
    end

    def process
      while @locations.present?
        puts @locations.length
        @locations.each do |loc|
          @location = loc
          unless location_params.blank?
            @data = Foursquare.send :fetch_data
            @meta = Foursquare.send :parse_metadata
            Foursquare.send :parse_data
            Foursquare.send :store_changes
            puts '.'
          end
        end
        @locations = Foursquare.send(:next)
      end
    end

    def post_process
    end

    def fetch_data
      begin
        http = Net::HTTP.new(Foursquare.uri.host, 443)
        http.use_ssl = true
        request = Net::HTTP::Get.new("#{uri.request_uri}?#{@params.to_param}")
        response = http.request(request)
        sleep(0.18)
        JSON.parse(response.body)
      rescue Exception => e
        puts "Exception #{e.message} for #{@location.location_nid} and #{request.inspect}\n===\n#{response.inspect}\n==="
        {}
      end
    end

    # stats: {
    #   checkinsCount: 2652
    #   usersCount: 2229
    #   tipCount: 56
    # }
    def parse_metadata
      @venues = @data['response']['venues'] if @data['response']
      @venue = @venues[0] if @venues
      stats = @venue['stats'] if @venue
      stats ||= {}
      {
        :location_nid => @location.location_nid,
        :fsq_checkins => (stats['checkinsCount'] || 0),
        :fsq_users => (stats['usersCount'] || 0),
        :fsq_tips => (stats['tipCount'] || 0),
        :fsq_categories => Foursquare.send(:collect_categories)
      }
    end

    def collect_categories
      begin
        @venue['categories'].map {|cat|
          {
            :name => cat['name'],
            :id => cat['id'],
            :short => cat['shortName']
          }
        }
      rescue Exception
        {}
      end
    end

    def parse_data
      @location.fsq_id = @venue['id'] if @venue
      @location.fsq_name = @venue['name'] if @venue
    end

    def store_changes
      Foursquare.send :store_metadata
      @location.save
    end

    def store_metadata
      Metadata.update_attributes(@meta,Metadata::VALID_FSQ)
    end

    def location_params
      @geo = Geolocation.find_by_location_nid(@location.location_nid)
      return false unless @geo.present? && @geo.lat.present? && @geo.lng.present? && @location.name.present?
      ll = "#{@geo.lat},#{@geo.lng}"
      @params = params.merge({ :query => @location.name, :ll => ll })
    end

    def next(lim=50)
      all = Location.limit(50).offset(@offset).find(:all)
      @offset += 50
      all
    end

  end
end

# {
# 
#     meta: {
#         code: 200
#     }
#     notifications: [
#         {
#             type: "notificationTray"
#             item: {
#                 unreadCount: 0
#             }
#         }
#     ]
#     response: {
#         venues: [
#             {
#                 id: "3fd66200f964a520d2ed1ee3"
#                 name: "House of Nanking"
#                 contact: {
#                     phone: "4154211429"
#                     formattedPhone: "(415) 421-1429"
#                 }
#                 location: {
#                     address: "919 Kearny St"
#                     crossStreet: "btw Jackson and Pacific"
#                     lat: 37.796516
#                     lng: -122.40513176666667
#                     distance: 15
#                     postalCode: "94133"
#                     city: "San Francisco"
#                     state: "CA"
#                     country: "USA"
#                 }
#                 categories: [
#                     {
#                         id: "4bf58dd8d48988d145941735"
#                         name: "Chinese Restaurant"
#                         pluralName: "Chinese Restaurants"
#                         shortName: "Chinese"
#                         icon: {
#                             prefix: "https://foursquare.com/img/categories/food/chinese_"
#                             sizes: [
#                                 32
#                                 44
#                                 64
#                                 88
#                                 256
#                             ]
#                             name: ".png"
#                         }
#                         primary: true
#                     }
#                 ]
#                 verified: false
#                 stats: {
#                     checkinsCount: 2652
#                     usersCount: 2229
#                     tipCount: 56
#                 }
#                 hereNow: {
#                     count: 0
#                 }
#             }
#         ]
#     }
# 
# }

## Sample HTTP
# require "net/http"
# require "uri"
# 
# uri = URI.parse("http://google.com/")
# 
# http = Net::HTTP.new(uri.host, uri.port)
# request = Net::HTTP::Get.new(uri.request_uri)
# 
# response = http.request(request)
# 
# response.code             # => 301
# response.body             # => The body (HTML, XML, blob, whatever)
# # Headers are lowercased
# response["cache-control"] # => public, max-age=2592000