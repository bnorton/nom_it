
class Geolocation < ActiveRecord::Base
  
  NUM = /^-?[0-9]+(\.[0-9]+)?$/
  TAG = /^[a-zA-Z_]+$/
  MIN_ENTRIES = 5
  
  belongs_to :location
  
  scope :default_distance, lambda { limit(10) }
  scope :distance, lambda { |lim| limit(lim)  }
  
  scope :find_by_distance, lambda {|lat,lng,dist|
    select("location_id").
    where(["DEGREES(ACOS(SIN(RADIANS(?))*SIN(RADIANS(lat))+COS(RADIANS(?))*COS(RADIANS(lat))*COS(RADIANS(?-lng))))*60*1.1515<?",lat,lat,lng,dist])
  }
  scope :search_by_category, lambda {|lat,lng,dist,category|
    Geolocation.find_by_distance(lat,lng,dist) # .where(["primary=? or secondary=?",category, category])
  }
  scope :search_by_categories, lambda {|lat,lng,dist,primary,secondary|
    Geolocation.search_by_category(lat,lng,dist,primary) # .search_by_category(lat,lng,dist,secondary)
  }
  
  def self.category_search(options,retries=3)
    if @lat.blank?
      params options
    end
    return false unless retries >= 0 && @primary =~ TAG
    locations = unless @secondary.blank?
      return false unless @secondary =~ TAG
      Geolocation.search_by_categories(@lat,@lng,@dist,@primary,@secondary)
    else
      Geolocation.search_by_category(@lat,@lng,@dist,@primary)
    end
    len = locations.length
    unless len > MIN_ENTRIES || same?(len)
      @last = len
      dist = Geolocation.new_distance(@dist)
      category_search(options,retries-1)
    end
    locations
  end
  
  def self.search_by_geolocation(options)
    params options
    return "search_by_geolocation didn't have the correct input values" unless lat && lng && lat.to_s =~ NUM && lng.to_s =~ NUM
    Geolocation.search(@lat,@lng,@dist) 
  end
  
  private
  
  def self.search(lat,lng,dist=0.5,retries=3)
    return false unless retries >= 0
    locations = Geolocation.find_by_distance(lat,lng,dist)
    len = locations.length
    unless len > MIN_ENTRIES || same?(len)
      @last = len
      dist = Geolocation.new_distance(dist)
      Geolocation.search(lat,lng,dist,retries-1)
    end
    locations
  end
  
  def self.params(options)
    @lat = options[:lat]
    @lng = options[:lng]
    @dist= options[:dist]
    @primary  =options[:primary]
    @secondary=options[:secondary]
  end
  
  def self.new_distance(dist)
    dist += 0.35      if dist < 1.25
    dist += dist*0.25 if dist >= 1
    dist
  end
  
  def self.same?(len)
    len && len > 0 && len == @last
  end
  
end

  # The schema for the geolocations model
  # create_table "geolocations", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.integer  "location_id",                  :null => false
  #   t.float    "lat",         :default => 0.0
  #   t.float    "lng",         :default => 0.0
  #   t.string   "nid"
  # end
  
  