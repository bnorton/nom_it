class Recommendation < ActiveRecord::Base
  require 'base64'
  
  belongs_to :user
  belongs_to :location
  
  COMPACT = "nid as recommendation_nid,user_nid,lat,lng,token,location_nid,location_name,location_city,title,text,created_at,image_nid"
  
  scope :OL, lambda {|offset,limit|
    offset(offset).limit(limit)
  }
  scope :compact, lambda {
    select(COMPACT)
  }
  scope :for_user, lambda {|nid|
    select(COMPACT).where(["user_nid=?", nid])
  }
  scope :for_location, lambda {|nid|
    compact.where(["location_nid=?",nid])
  }
  scope :for_nid, lambda {|nid|
    compact.where(["nid=?",nid])
  }
  scope :for_token, lambda {|token|
    compact.where(["token=?",token])
  }
  
  def self.create(this)
    this.merge!(self.defaults(this))
    r = Recommendation.new
    r.lat      = this[:lat]
    r.lng      = this[:lng]
    r.user_nid  = this[:user_nid]
    r.user_name= this[:user_name]
    r.location_nid = this[:location_nid]
    r.title    = this[:title]
    r.text     = this[:text]
    r.facebook = this[:facebook] || false
    r.facebook = this[:twitter]  || false
    r.location_name = this[:name]
    r.location_city = this[:city]
    r.nid      = Util.ID
    r.token = this[:token] || Util.token
    if r.save
      Metadata.recommended(r.nid) # for item analytics
      r.reload
      r
    end
  end
  
  def self.defaults(this)
    location = {}
    result = Location.find_by_nid(this[:location_nid])
    return location if result.blank?
    location[:text] = this[:text] || "I recommended #{result.name || '...'} via Nom."
    location[:name] = result.name
    location[:city] = result.city
    location
  end
  
end

  # the Schema for the Recommendation model
  # create_table "recommendations", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.string   "nid"
  #   t.string   "user_nid",                         :null => false
  #   t.string   "user_name"
  #   t.string   "location_nid"
  #   t.string   "location_name"
  #   t.string   "location_city"
  #   t.string   "token"
  #   t.string   "title"
  #   t.text     "text"
  #   t.boolean  "facebook",      :default => false
  #   t.boolean  "twitter",       :default => false
  #   t.float    "lat"
  #   t.float    "lng"
  #   t.boolean  "new",           :default => true
  #   t.binary   "schemaless"
  #   t.boolean  "is_valid",      :default => true
  #   t.string   "image_nid"
  # end
