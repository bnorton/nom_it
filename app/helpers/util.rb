class Util
  class << self
    
    def nidify(item)
      item[:nid] = item['_id'].to_s
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
    
    def prepare(items,opt={})
      ii = []
      items.each do |it|
        ii << Util.nidify(it)
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
    
  end
end