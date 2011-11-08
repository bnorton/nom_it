class Util
  class << self
    
    def nidify(item, key)
      item[key] = item['_id'].to_s
      item.delete('_id')
      item
    end
  
    def translate!(items, mapper)
      items.each do |it|
        mapper.each do |k,v|
          it[v] = it.delete(k.to_s) if it.has_key? k.to_s
        end
      end
    end
    
    # a mongo cursor
    def parse(cursor,opt={})
      key = opt[:key] || :nid
      ii = []
      cursor.count.times do
        it = cursor.next
        ii << Util.nidify(it,key)
      end
      ii
    end
    
    def prepare(items,opt={})
      key = opt[:key] || :nid
      ii  = []
      items.each do |it|
        ii << Util.nidify(it,key)
      end
      ii
    end
    
    def parse_location(location)
      begin
        city_state = location['name']
        unless city_state.nil?
          parts = city_state.split
          if parts.length > 1
            return [parts[0].strip, parts[1].strip]
          end
          city_state
        end
      rescue Exception
        nil
      end
    end
    
    def ID
      BSON::ObjectId.new.to_s
    end
    
    def placefinder
      @placefinder ||= Placefinder::Base.new(:api_key => YAHOO_API_KEY)
    end
    
    def geocode_address(addr)
      placefinder.get(:q => addr, :gflags => YAHOO_GFLAGS)
    end
    
    def reverse_geocode_address(lat,lng)
      placefinder.get(:q => "#{lat},#{lng}", :gflags => YAHOO_GFLAGS_REV)
    end
    
  end
end