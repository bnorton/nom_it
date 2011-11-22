class Recommendation < ActiveRecord::Base
  require 'base64'
  
  belongs_to :user
  belongs_to :location
  
  COMPACT = "id,nid,user_nid,lat,lng,token,location_nid,location_name,location_city,title,text,updated_at,image"
  
  scope :OL, lambda {|offset,limit|
    offset(offset).limit(limit)
  }
  scope :compact, lambda {
    Recommendation.select(COMPACT)
  }
  scope :for_user, lambda {|nid|
    compact.where(["user_nid=?",id])
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
    if r.save
      Metadata.recommended(r.nid) # for item analytics
      token = Base64.encode64(r.id.to_s)
      token = token.gsub('=','').gsub('\n','')
      r.token = token
      r.save
      [token,User.find_by_token(token)]
    end
  end
  
  def self.defaults(this)
    location = {}
    result = Location.detail_for_nid(this[:location_nid]).try(:first)
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
  #   t.integer  "user_id",                          :null => false
  #   t.string   "token"
  #   t.integer  "location_id",                      :null => false
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
  #   t.string   "image"
  #   t.string   "user_name"
  #   t.string   "nid"
  # end
