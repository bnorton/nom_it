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
    
    def ID
      BSON::ObjectId.new
    end
    
  end
end