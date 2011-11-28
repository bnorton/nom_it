require "net/http"
require "uri"

class Foursquare
  class << self
    
    def fetch
      pre_process
      process
      post_process
    end
      
    def pre_process
    end
    def process
    end
    def post_process
    end
    
  end
end



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