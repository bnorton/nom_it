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
    return false if recommendation.blank? || followers.blank?
    r = recommendation
    followers.each do |follower_nid|
      Recommend.save({
        :rnid => r.recommendation_nid,
        :lnid => r.location_nid,
        :inid => r.image_nid,
        :unid => r.user_nid,
        :uname => r.user_name,
        :to_unid => follower_nid,
        :token => r.token,
        :title => r.title,
        :text => r.text,
        :lat => r.lat,
        :lng => r.lng
      })
    end
  end

  def self.by_user_nid(nid, limit=10)
    nid = Util.STRINGify(nid)
    limit = Util.limit(limit,10)
    Recommend.find({:unid => nid}).limit(limit).map{ |rec|
      Recommend.build(rec)
    }
  end

  def self.for_user_nid(nid, limit=10)
    nid = Util.STRINGify(nid)
    limit = Util.limit(limit,10)
    Recommend.find({:to_unid => nid}).limit(limit).map{ |rec|
      Recommend.build(rec)
    }
  end

  def self.for_location_nid(nid, limit=10)
    nid = Util.STRINGify(nid)
    limit = Util.limit(limit,10)
    Recommend.find({:lnid => nid}).limit(limit).map{ |rec|
      Recommend.build(rec)
    }
  end

  def self.for_token(token, limit=10)
    Recommend.find({:token => token}).limit(limit).map{ |rec|
      Recommend.build(rec)
    }
  end

  def self.build(rec)
    Rails.cache.fetch("recommended_item_#{rec['_id']}", :expires_in => 3.days) do
      rec = Recommend.clean(rec)
      Recommend.image(rec)
      rec
    end
  end
  
  def self.clean(rec)
    rec = Util.de_nid(rec, '_id')
    rec = Util.nidify(rec, 'location_nid', 'lnid')
    rec = Util.nidify(rec, 'user_nid', 'unid')
    rec = Util.nidify(rec, 'user_name', 'uname')
    rec = Util.nidify(rec, 'recommendation_nid', 'rnid')
    rec
  end
  
  def self.image(rec)
    inid = rec.delete('inid')
    rec[:image] = Image.for_nid(inid) if inid.present?
    rec
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
