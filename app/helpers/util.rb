class Util
  class << self
    
    def nidify(item,key,id='_id')
      return item unless item.respond_to?(:[])
      item[key] = Util.STRINGify(item.delete(id))
      item
    end
    
    def de_nid(item,key=:nid)
      item.delete(key) if item.respond_to?(:delete)
      item
    end
    
    def translate!(items, mapper)
      items.each do |it|
        mapper.each_pair do |k,v|
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
    
    def STRINGify(s)
      return if s.blank?
      return s.to_s if s.respond_to? :to_s
      s
    end
    
    def BSONify(id)
      return id if (id.blank? || id.is_a?(BSON::ObjectId))
      begin
        return BSON::ObjectId(id)
      rescue BSON::InvalidObjectId
        id
      end
    end
    
    def ensure_limit(start,limit,min=5,max=50)
      start = start.to_i
      start = start > 0 ? start : 0
      limit = limit.to_i
      limit = limit <= min ? start + min : limit > start + max ? start + max : limit
      [start,limit]
    end
    
    def limit(num,max=20,min=5)
      lim = lim.to_i
      lim < min ? min : lim > max ? max : lim
    end
    
    def BSONID
      BSON::ObjectId.new
    end
    
    def ID
      BSON::ObjectId.new.to_s
    end
    
    def token
      rand(RAND_SEED).to_s(36)
    end
    
    def placefinder
      @placefinder ||= Placefinder::Base.new(:api_key => YAHOO_API_KEY)
    end
    
    def geocode_address(addr)
      begin
        placefinder.get(:q => addr, :gflags => YAHOO_GFLAGS)
      rescue Exception
        {}
      end
    end
    
    def reverse_geocode(lat,lng)
      begin
        placefinder.get(:q => "#{lat},#{lng}", :gflags => YAHOO_GFLAGS_REV)
      rescue Exception
        {}
      end
    end
    
  end
end