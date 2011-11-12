class Location < ActiveRecord::Base
  
  COMPACT = "id,nid,updated_at,name,address,cross_street,street,city,state,fsq_id,gowalla_url"
  
  has_many :images
  has_one  :geolocation
  has_one  :statistic
  
  scope :compact, lambda {
    select(COMPACT)
  }
  scope :detail_for_nid, lambda {|nid| 
    detail_for_ids(nid)
  }
  scope :detail_for_nids, lambda {|nids| 
    compact.where(["nid in (?)", nids.split(',')])
  }
  scope :find_by_like_name, lambda {|name|
    compact.where(["name like ?","%#{name}%"])
  }
  scope :find_by_address_parts, lambda {|street,city|
    unless city.blank?
      compact.where(["(address like ? or street like ?) and city like ?","%#{street}%","%#{street}%","%#{city}%"])
    else
      compact.where(["street like ? or address like ?","%#{street}%","%#{street}%"])
    end
  }
  
  def self.create_item(opt,optional={})
    new_nid = Util.ID
    created_loc = Location.find_or_create_by_name_and_creator(
      :name => opt[:name],
      :creator => opt[:nid],
      :primary => opt[:primary],
      :secondary => opt[:secondary],
      :city => opt[:city],
      :text => opt[:text],
      :phone => opt[:phone],
      :cost => opt[:cost],
      :nid => new_nid)
    opt.merge!({:location_nid => new_nid})
    created_geo = Geolocation.create_item(opt)
    return true if created_loc && created_geo
  end
  
  # @optional :nid
  # @optional :name
  # @optional :street
  # @optional :city
  def self.search(opt,start=0,lim=10)
    nid = Util.BSONify(opt[:nid])
    name = opt[:name]
    street = opt[:street]
    city = opt[:city]
    if nid
      result = compact.find_by_nid(nid).limit(lim).as_json
      built = Array(Location.detail_for_nid(result['nid'],location=result))
    else
      if opt[:lat] && opt[:lng]
        results = Geolocation.search(opt)
        what = :geolocation
      else
        results = search_by_name_street_city(name,street,city,lim)
        what = :location
      end
      built = build_results(results,what)
    end
    built
  end
  
  def self.detail_for_nid(nid,location=nil,geolocation=nil)
    nid = Util.STRINGify(nid)
    if location.present?
      detail = location.as_json
    else
      detail = find_by_nid(nid).as_json
    end
    Metadata.returned(nid)
    thumb = Thumb.detail_for_nid(nid)
    meta = Metadata.for_nid(nid)
    geo = geolocation || Geolocation.for_nid(nid).as_json
    detail.merge({
      :thumbs => thumb,
      :metadata => meta,
      :geolocation => geo
    })
  end
  
  def self.full_detail_for_nids(nids)
    locations = []
    nids.each do |nid|
      locations << Location.detail_for_nid(nid)
    end
    locations
  end
  
  def self.build_results(results,what=:location)
    real_result = []
    unless results.blank? || !(results = results.as_json)
      results.each do |result|
        real_result << if what == :location
          Location.detail_for_nid(result['nid'],result)
        elsif what == :geolocation
          Location.detail_for_nid(result['location_nid'],nil,result)
        else
          Location.detail_for_nid(result['nid'])
        end
      end
    end
    real_result
  end
  
  def self.details_from_search(search)
      locations = Location.parse_ids search
      Location.detail_for_ids(locations)
    end
    
  
  def self.parse_ids(search)
    locations = []
    search.each do |locid|
      locations << locid.location_nid
    end
    locations.join(',')
  end
  
  def self.integer_cost(str)
    return 0 unless str =~ /\$+/
    return 4 if str.length > 3
    str.length
  end
  
  private 
  
  def self.search_by_name_street_city(name,street,city,lim)
    if name && street
      find_by_like_name(name).find_by_address_parts(street,city).limit(lim)
    elsif name
      find_by_like_name(name).limit(lim)
    elsif street
      find_by_address_parts(street,city).limit(lim)
    end
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