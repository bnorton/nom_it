class Location < ActiveRecord::Base
  
  COMPACT = "id,nid,updated_at,name,address,cross_street,street,city,state,fsq_id,gowalla_url"
  
  has_many :images
  has_one  :geolocation
  has_one  :statistic
  
  scope :compact, lambda {
    select(COMPACT)
  }
  scope :detail_for_id, lambda {|id| 
    detail_for_ids(id.to_s)
  }
  scope :detail_for_ids, lambda {|ids| 
    compact.where(["id in (?)", ids.split(',')])
  }
  scope :find_by_like_name, lambda {|name|
    compact.where(["name like ?","%#{name}%"])
  }
  scope :find_by_address_parts, lambda {|street,city|
    unless city.blank?
      compact.where(["street like ? and city like ?","%#{street}%","%#{city}%"])
    else
      compact.where(["street like ?","%#{street}%"])
    end
  }
  
  def self.search(opt,start=0,lim=10)
    nid = opt[:nid]
    name = opt[:name]
    st = opt[:street]
    ci = opt[:city]
    
    if nid
      result = compact.find_by_nid(nid)
      puts "result #{result.inspect}"
      real_result = [Location.detail_for_nid(result['nid'],location=result)]
    else
      result = if name && st && ci
        find_by_like_name(name).find_by_address_parts(st,ci)
      elsif name
        find_by_like_name(name).limit(lim)
      elsif st && ci
        find_by_address_parts(st,ci)
      end.limit(lim)
      
      result.each do |res|
        real_result << Location.detail_for_nid(res['nid'],location=res)
      end
    end
    real_result
  end
  
  def self.detail_for_nid(nid,location_id=nil,location=nil,geolocation=nil)
    if location_id.present?
      detail = compact.find_by_id(location_id).attributes
    elsif location.present?
      detail = location
    else
      detail = find_by_nid(nid).attributes
    end
    nid = detail['nid']
    thumb = ThumbCount.find_by_nid(nid)
    meta = Metadata.find_by_nid(nid)
    geo = geolocation || Geolocation.for_nid(nid).try(:attributes)
    detail.merge({
      :thumbs => thumb,
      :metadata => meta,
      :geolocation => geo
    })
  end
  
  def self.full_detail_for_ids(ids)
    locations = []
    ids.each do |id|
      locations << Location.detail_for_nid(nil,id)
    end
    locations
  end
  
  def self.details_from_search(search)
      locations = Location.parse_ids search
      details   = Location.detail_for_ids(locations)
    end
    
  def self.full_details_from_search(search)
    locations = Location.parse_ids search
    details   = Location.full_detail_for_ids(locations)
  end
  
  def self.parse_ids(search)
    locations = []
    search.each do |locid|
      locations << locid.location_id
    end
    locations.join(',')
  end
  
  def self.integer_cost(str)
    return 0 unless str =~ /\$+/
    return 4 if str.length > 3
    str.length
  end
  
end

  # create_table "locations", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.string   "name"
  #   t.string   "fsq_name"
  #   t.string   "fsq_id"
  #   t.string   "gowalla_url"
  #   t.string   "gowalla_name"
  #   t.string   "address"
  #   t.string   "cross_street"
  #   t.string   "street"
  #   t.string   "street2"
  #   t.string   "city"
  #   t.string   "state"
  #   t.string   "area_code",     :limit => 7
  #   t.string   "country"
  #   t.text     "json_encode"
  #   t.boolean  "is_new",                     :default => false, :null => false
  #   t.string   "code"
  #   t.binary   "schemaless"
  #   t.string   "primary"
  #   t.string   "secondary"
  #   t.string   "nid"
  #   t.string   "hash"
  #   t.string   "yid"
  #   t.string   "woeid"
  #   t.string   "neighborhoods"
  #   t.string   "url"
  #   t.string   "revision_id"
  #   t.string   "twitter"
  #   t.string   "facebook"
  #   t.string   "phone"
  #   t.string   "cost"
  #   t.string   "timeofday"
  #   t.string   "metadata_id"
  # end