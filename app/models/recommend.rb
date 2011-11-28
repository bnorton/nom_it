require 'mongo_ruby'

class Recommend < MongoRuby
  # rid => recommendation_nid
  # unid => user_nid
  # 
  attr_accessor :rnid,  :unid,  :uname, :to_unid
  attr_accessor :token, :name,  :city
  attr_accessor :text,  :title, :lat,   :lng
  attr_accessor :time,  :inid,  :lnid,  :viewed
    
  def self.dbcollection
    "recommends"
  end

  def self.removed_content_message
    "the user has removed this recommendation."
  end

  def self.create(recommendation,followers)
    raise "#{recommendation.inspect}, #{followers.inspect}"
    
    return false if recommendation.blank? || followers.blank?
    r = recommendation
    followers.each do |follower_nid|
      Recommend.save({
        :lat => r.lat,
        :lng => r.lng,
        :unid => r.user_nid,
        :uname => r.user_name,
        :lnid => r.location_nid,
        :title => r.title,
        :text => r.text,
        :to_unid => follower_nid,
        :name => r.location_name,
        :city => r.location_city,
        :rnid => r.recommendation_nid,
        :token => r.token #,
        # :inid => r.image_nid
      })
    end
  end
  
  def self.destroy()
    
  end
  
  def self.by_user_nid(nid, limit=10)
    nid = Util.STRINGify(nid)
    limit = Util.limit(limit,10)
    Recommend.find({:unid => nid}).limit(limit)
  end
  
  def self.for_user_nid(nid, limit=10)
    nid = Util.STRINGify(nid)
    limit = Util.limit(limit,10)
    Recommend.find({:to_unid => nid}).limit(limit)
  end
  
  def self.for_location_nid(nid, limit=10)
    nid = Util.STRINGify(nid)
    limit = Util.limit(limit,10)
    Recommend.find({:lnid => nid}).limit(limit)
  end
  
  def self.for_token(token)
    Recommend.find({:token => token})
  end
  
end

  # the Schema for the Recommendation model 
  
### This object is the `each individual item` table
  
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
  #   t.string    "image"
  # end
