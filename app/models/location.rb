class Location < ActiveRecord::Base
  class NotDeactivated < Exception; end
  COMPACT = "location_nid,rank,rank_value,yid,woeid,url,timeofday,primary_category,secondary_category,neighborhoods,phone,cost,created_at,updated_at,name,address,cross_street,street,city,state,fsq_id,gowalla_url"
  # COMPACT = "*"
  has_many :images
  has_one  :geolocation
  has_one  :statistic

  scope :OL, lambda {|offset,limit|
    offset(offset).limit(limit)
  }
  scope :compact, lambda {
    select(COMPACT)
  }
  scope :detail_for_nid, lambda {|nid| 
    detail_for_nids(nid)
  }
  scope :detail_for_nids, lambda {|nids| 
    compact.where(["location_nid in (?)", nids.split(',')])
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
      :creator => opt[:user_nid],
      :primary_category => opt[:primary],
      :secondary_category => opt[:secondary],
      :city => opt[:city],
      :text => opt[:text],
      :phone => opt[:phone],
      :cost => opt[:cost],
      :location_nid => new_nid)
    opt.merge!({:location_nid => new_nid})
    created_geo = Geolocation.create_item(opt)
    return true if created_loc && created_geo
  end
  
  # @optional :nid
  # @optional :name
  # @optional :street
  # @optional :city
  def self.search(opt,start=0,lim=10)
    location_nid = Util.STRINGify(opt[:location_nid])
    query = opt[:query]
    street = opt[:street]
    city = opt[:city]
    dist=nil
    if location_nid.present?
      result = compact.OL(start,lim).order(:rank_value).find_by_location_nid(location_nid)
      built = Array(Location.detail_for_nid(result['location_nid'],location=result))
    else
      if query.present? || street.present?
        results = search_by_name_street_city(query,street,city,lim)
        what = :location
      elsif (lat=opt[:lat]) && (lng=opt[:lng])
        dist=(opt[:dist]||0.5);primary=opt[:primary];secondary=opt[:secondary];
        start=opt[:start];limit=opt[:limit]
        results,dist = Geolocation.search(lat,lng,dist,primary,secondary,start,limit)
        what = :geolocation
      else
        return [[],0.0]
      end
      built = build_results(results,what)
    end
    [built,dist]
  end
  
  def self.compact_detail_for_nid(location_nid)
    return {} if location_nid.blank?
    Rails.cache.fetch("compact_detail_for_nid_#{location_nid}", :expires_in => 10.minutes) do
      Location.compact.find_by_location_nid(location_nid) || {}
    end
  end
  
  def self.detail_for_nid(location_nid,location=nil,geolocation=nil)
    location_nid = Util.STRINGify(location_nid)
    if location.present?
      detail = location.as_json
    else
      detail = Location.compact_detail_for_nid(location_nid).as_json
    end
    meta = Metadata.for_nid(location_nid)
    thumb = Thumb.detail_for_nid(location_nid)
    images = Image.for_location_nid(location_nid)
    average = RankingAverage.ranking_total(location_nid)
    geo = geolocation || Geolocation.for_location_nid(location_nid)
    detail.merge({
      :metadata => meta,
      :geolocation => geo,
      :images => images,
      :ranking => average
    }).merge(thumb)
  end
  
  def self.full_detail_for_nids(nids)
    locations = []
    nids = [nids] unless nids.is_a? Array
    nids.each do |nid|
      locations << Location.detail_for_nid(nid)
    end
    locations
  end
  
  def self.build_results(results,what=:location)
    real_result = []
    unless results.blank? || !(results = results.as_json)
      results.each do |result|
        location_nid = result['location_nid']
        real_result << if what == :location
          Location.detail_for_nid(location_nid,result)
        elsif what == :geolocation
          Location.detail_for_nid(location_nid,nil,result)
        else
          Location.detail_for_nid(location_nid)
        end
      end
    end
    real_result
  end
  
  def self.integer_cost(str)
    return 0 unless str =~ /\$+/
    return 4 if str.length > 3
    str.length
  end
  
  private 
  
  def fsq_ignore!
    transaction do
      self.fsq_ignore = true
      self.fsq_name = nil
      self.fsq_id = nil
      begin
        self.save!
      rescue Exception
        raise Location::NotDeactivated
        return
      end
      meta = {
        :location_nid => self.location_nid,
        :fsq_checkins => 0,
        :fsq_users => 0,
        :fsq_tips => 0,
        :fsq_categories => {}
      }
      raise Location::NotDeactivated unless Metadata.update_attributes(meta,Metadata::VALID_FSQ)
    end
    true
  end
  
  def self.search_by_name_street_city(query,street,city,lim)
    if query && street
      find_by_like_name(query).find_by_address_parts(street,city).limit(lim)
    elsif query
      find_by_like_name(query).limit(lim)
    elsif street
      find_by_address_parts(street,city).limit(lim)
    end
  end
  
  def remove_from_searches
    Geolocation.find_by_location_nid(self.location_nid).try(:destroy)
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
  #   t.string   "primary_category"
  #   t.string   "secondary_category"
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
  
  
  
  # detail_for_nid => {
  #   "name"=>"Roppolo's Pizzeria", 
  #   "is_new"=>"false", 
  #   "fsq_id"=>"null", 
  #   "city"=>"Austin", 
  #   "address"=>"316 E 6th St Austin, TX 78701-3628", 
  #   "woeid"=>"12792283", 
  #   "created_at"=>"2011-11-21T03:14:31Z", 
  #   "ranking"=>
  #   {
  #   }, 
  #   "location_hash"=>"dfbf46227f1fe4d375148ce3c00486ac37ef26c1c2281f3a4b027c211e481d6c", 
  #   "country"=>"United States", 
  #   "cost"=>"$", 
  #   "code"=>"null", 
  #   "area_code"=>"78701-3628", 
  #   "updated_at"=>"2011-11-21T03:14:31Z", 
  #   "creator"=>"null", 
  #   "metadata"=>
  #   {
  #     "location_nid"=>"4ec9c2173c61671ebe0005ff", 
  #     "yelp_rating"=>2.5, 
  #     "ret"=>0, 
  #     "rec_c"=>0, 
  #     "rank"=>0, 
  #     "meh"=>0, 
  #     "up"=>0, 
  #     "views"=>1, 
  #     "categories"=>
  #     [
  #       "pizza",
  #       "italian"
  #     ], 
  #     "yelp_count"=>94, 
  #     "rank_c"=>0
  #   }, 
  #   "url"=>"null", 
  #   "timeofday"=>"dessert | latenight", 
  #   "street2"=>"null", 
  #   "schemaless"=>"null", 
  #   "primary"=>"4ec5ad3f3c6167f601000027", 
  #   "json_encode"=>"null", 
  #   "street"=>"316 E 6th St", 
  #   "revision_nid"=>"null", 
  #   "id"=>13065, 
  #   "gowalla_name"=>"null", 
  #   "cross_street"=>"Between San Jacinto Blvd and Trinity St", 
  #   "geolocation"=>
  #   {
  #     "location_nid"=>"4ec9c2173c61671ebe0005ff", 
  #     "lng"=>-97.7401351928711, 
  #     "lat"=>30.2673301696777
  #   }, 
  #   "images"=>
  #   [
  #   ], 
  #   "phone"=>"512-476-1490", 
  #   "neighborhoods"=>"6th Street District | Downtown", 
  #   "thumbs"=>[], 
  #   "thumb_count"=>
  #   {
  #     "up" => 0, 
  #     "meh" => 0
  #   }
  #   "fsq_name"=>"null", 
  #   "facebook"=>"null", 
  #   "yid"=>"2474197075808616171", 
  #   "secondary"=>"4ec954593c61671c7e0000a9", 
  #   "nid"=>"4ec9c2173c61671ebe0005ff", 
  #   "metadata_nid"=>"null", 
  #   "gowalla_url"=>"null", 
  #   "twitter"=>"null", 
  #   "state"=>"Texas"
  # } 
  # 
  
  
  