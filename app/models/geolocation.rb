
class Geolocation < ActiveRecord::Base
  
  NUM = /^-?[0-9]+(\.[0-9]+)?$/
  TAG = /^[a-zA-Z_]+$/
  MIN_ENTRIES = 5
  
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
  
  def self.category_search(lat,lng,dist,primary,secondary='',retries=3)
    return false unless retries >= 0
    return false unless primary =~ TAG
    locations = unless secondary.blank?
      return false unless secondary =~ TAG
      Geolocation.search_by_categories(lat,lng,dist,primary,secondary)
    else
      Geolocation.search_by_category(lat,lng,dist,primary)
    end
    len = locations.length
    unless len > MIN_ENTRIES || same?(len)
      @last = len
      dist = Geolocation.new_distance(dist)
      category_search(lat,lng,dist,primary,secondary,retries-1)
    end
    locations
  end
  
  def self.search_by_geolocation(lat,lng,dist)
    return "search_by_geolocation went wrong" unless lat && lng && lat.to_s =~ NUM && lng.to_s =~ NUM
    Geolocation.search(lat,lng,dist) 
  end
  
  private
  
  def self.search(lat,lng,dist,retries=3)
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
  
  def self.new_distance(dist)
    dist += 0.35       if dist < 1.25
    dist += dist*0.25  if dist >= 1
    dist
  end
  
  def self.same?(len)
    len && len > 0 && len == @last
  end
  
end


  # The schema for the geolocations model
  # create_table "geolocations", :force => true do |t|
  # t.datetime "created_at"
  # t.datetime "updated_at"
  # t.integer  "location",                    :null => false
  # t.float    "lat",        :default => 0.0
  # t.float    "lng",        :default => 0.0
  #
  #
  
  