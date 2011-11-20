require 'ostruct'
class Geolocation < ActiveRecord::Base
  
  NUM = /^-?[0-9]+(\.[0-9]+)?$/
  MIN_ENTRIES = 5
  
  belongs_to :location
  
  scope :default_distance, lambda { limit(10) }
  scope :distance, lambda { |lim| limit(lim)  }
  scope :compact, lambda  {
    select("lat,lng")
  }
  scope :find_by_distance, lambda {|lat,lng,dist|
    select("location_nid").
    where(["(DEGREES(ACOS(SIN(RADIANS(#{lat}))*SIN(RADIANS(lat))+COS(RADIANS(#{lat}))*COS(RADIANS(lat))*COS(RADIANS(#{lng}-lng))))*60*1.1515)<?",dist])
  }
  scope :search_by_category, lambda {|lat,lng,dist,primary|
    Geolocation.find_by_distance(lat,lng,dist).where(["primary=?",primary])
  }
  scope :search_by_categories, lambda {|lat,lng,dist,primary,secondary|
    Geolocation.find_by_distance(lat,lng,dist).where(["primary=? or secondary=?",primary,secondary])
  }
  
  def self.create_item(opt)
    if ((nid = opt[:location_nid]) && (lat = opt[:lat]) && (lng = opt[:lng]))
      Geolocation.find_or_create_by_nid_and_lat_and_lng(
        :nid => nid,
        :lat => lat,
        :lng => lng,
        :cost => opt[:cost],
        :primary => opt[:primary],
        :secondary => opt[:secondary])
    end
  end
  
  def self.for_nid(nid)
    nid = Util.STRINGify(nid)
    geo = (find_by_location_nid(nid) || {}).as_json
    geo = Util.nidify(geo,:primary,'primary')
    Util.nidify(geo,:secondary,'secondary')
  end
  
  def self.search(options,retries=3)
    if @lat.blank? || @lng.blank?
      params options
    end
    return false if retries < 0
    locations = if @primary.present?
      if @secondary.present?
        Geolocation.search_by_categories(@lat,@lng,@dist,@primary,@secondary)
      else
        Geolocation.search_by_category(@lat,@lng,@dist,@primary)
      end
    else
      Geolocation.find_by_distance(@lat,@lng,@dist)
    end
    len = locations.length
    unless len > MIN_ENTRIES || same?(len)
      @last = len
      @dist = Geolocation.new_distance(@dist)
      search(options,retries-1)
    end
    locations
  end
  
  private
  
  def self.params(options)
    @lat = options[:lat].try(:to_f)
    @lng = options[:lng].try(:to_f)
    @dist = options[:dist].try(:to_f) || 0.5
    @primary = options[:primary]
    @secondary = options[:secondary]
  end
  
  def self.new_distance(dist)
    dist = dist
    dist += 0.35      if dist < 1.25
    dist += dist*0.25 if dist >= 1
    dist
  end
  
  def self.same?(len)
    len && len > 0 && len == @last
  end
  
end

  # create_table "geolocations", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.integer  "location_id",                  :null => false
  #   t.float    "lat",         :default => 0.0
  #   t.float    "lng",         :default => 0.0
  #   t.integer  "cost"
  #   t.string   "primary"
  #   t.string   "secondary"
  #   t.string  "location_nid"
  # end
  