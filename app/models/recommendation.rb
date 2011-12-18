class Recommendation < ActiveRecord::Base
  require 'base64'

  belongs_to :user
  belongs_to :location

  COMPACT = "recommendation_nid,location_nid,user_nid,image_nid,lat,lng,token,title,text,created_at"

  scope :OL, lambda {|offset,limit|
    offset(offset).limit(limit)
  }
  scope :compact, lambda {
    select(COMPACT)
  }

  def self.create(this)
    r = Recommendation.new
    rnid = Util.ID
    r.recommendation_nid = rnid
    r.token = this[:token] || Util.token
    r.user_nid = this[:user_nid]
    r.location_nid = this[:location_nid]
    r.image_nid = this[:image_nid]
    r.title = this[:title]
    r.text = this[:text].present? ? "#{this[:text]} justnom.it/r/#{r.token}" : "I Nommed @ #{r.location_name || '...'} via Nom. justnom.it/r/#{r.token}"
    r.facebook = this[:facebook] || false
    r.twitter = this[:twitter]  || false
    r.lat = this[:lat]
    r.lng = this[:lng]
    if r.save
      Metadata.recommended(rnid) # for item analytics
      r
    end
  end

  class << self

    def common(items)
      items.map{|it|
        it = it.as_json
        image_nid = it.delete 'image_nid'
        it[:image] = Image.for_nid(image_nid) || {}
        location_nid = it.delete 'location_nid'
        it[:location] = Location.compact_detail_for_nid(location_nid) || {}
        it
      }
    end

    def for_user(nid)
      common Recommendation.compact.order('id DESC').find_all_by_user_nid(nid)
    end

    def for_location(nid)
      common Recommendation.compact.order('id DESC').find_all_by_location_nid(nid)
    end

    def for_nid(nid)
      common Recommendation.compact.order('id DESC').find_all_by_recommendation_nid(nid)
    end

    def for_token(token)
      common Recommendation.compact.order('id DESC').find_all_by_token(token)
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
