class Recommendation < ActiveRecord::Base
  require 'base64'
  
  COMPACT = "id,user_id,lat,lng,token,location_id,location_name,location_city,title,text,created_at,image"
  
  scope :compact, lambda {
    Recommendation.select(COMPACT)
  }
  scope :for_user, lambda {|id|
    compact.where(["user_id=?",id])
  }
  scope :for_location, lambda {|id|
    compact.where(["location_id=?",id])
  }
  
  def self.create(this)
    this.merge!(self.defaults(this))
    
    recommendation = Recommendation.new do |r|
      r.lat      = this[:lat]
      r.lng      = this[:lng]
      r.user_id  = this[:user_id]
      r.user_name= this[:user_name]
      r.location_id = this[:location_id]
      r.title    = this[:title]
      r.text     = this[:text]
      r.facebook = this[:facebook] || false
      r.facebook = this[:twitter]  || false
      r.location_name = this[:name]
      r.location_city = this[:city]
    end
    if recommendation.save!
      token = Base64.encode64(recommendation.id.to_s)
      token = token.gsub("=","").gsub("\n","")
      recommendation.token = token
      recommendation.save!
      [token,recommendation]
    end
  end
  
  def self.defaults(this)
    location = {}
    
    result = Location.detail_for_id(this[:location_id]).try(:first)
    return location if result.blank?
    location[:text] = this[:text] || "#{result.name || this} is a great spot and I recommend it...Nom Away!"
    location[:name] = result.name
    location[:city] = result.city
    
    location
  end
  
end

  # the Schema for the Recommendation model
  # create_table "recommendations", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.integer  "user",                             :null => false
  #   t.string   "token"
  #   t.integer  "location",                         :null => false
  #   t.string   "location_name"
  #   t.string   "location_city"
  #   t.string   "title"
  #   t.text     "text"
  #   t.boolean  "facebook",      :default => false
  #   t.boolean  "twitter",       :default => false
  #   t.float    "lat"
  #   t.float    "lng"
  #   t.boolean  "new",           :default => true
  #   t.binary   "schemaless"
  #   t.boolean  "is_valid",      :default => true
  # end
