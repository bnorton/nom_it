class Recommendation < ActiveRecord::Base
  require 'base64'

  belongs_to :user
  belongs_to :location

  COMPACT = "recommendation_nid,user_nid,lat,lng,token,location_nid,location_name,location_city,title,text,created_at,image_nid"

  scope :OL, lambda {|offset,limit|
    offset(offset).limit(limit)
  }
  scope :compact, lambda {
    select(COMPACT)
  }

  def self.create(this)
    this.merge!(self.defaults(this))
    r = Recommendation.new
    r.lat = this[:lat]
    r.lng = this[:lng]
    r.user_nid = this[:user_nid]
    r.user_name = this[:user_name]
    r.location_nid = this[:location_nid]
    r.title = this[:title]
    r.facebook = this[:facebook] || false
    r.facebook = this[:twitter]  || false
    r.location_name = this[:name]
    r.location_city = this[:city]
    r.image_nid = this[:image_nid]
    rnid = Util.ID
    r.recommendation_nid = rnid
    r.token = this[:token] || Util.token
    if this[:text]
      r.text = "#{this[:text]} justnom.it/r/#{r.token}"
    else
      r.text = "I Nommed @ #{r.location_name || '...'} via Nom. justnom.it/r/#{r.token}"
    end
    if r.save
      Metadata.recommended(rnid) # for item analytics
      r
    end
  end

  class << self
    def defaults(this)
      location = {}
      result = Location.find_by_location_nid(this[:location_nid]) if this[:location_nid].present?
      return location if result.blank?
      location[:name] = result.name
      location[:city] = result.city
      location
    end

    def for_user(nid)
      compact.order('id DESC').find_all_by_user_nid(nid)
    end

    def for_location(nid)
      compact.order('id DESC').find_all_by_location_nid(nid)
    end

    def for_nid(nid)
      compact.order('id DESC').find_all_by_recommendation_nid(nid)
    end

    def for_token(token)
      compact.order('id DESC').find_all_by_token(token)
    end
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
