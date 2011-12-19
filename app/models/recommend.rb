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
    Recommend.fetch_and_build({:unid => nid},limit)
  end

  def self.for_user_nid(nid, limit=10)
    Recommend.fetch_and_build({:to_unid => nid},limit)
  end

  def self.for_location_nid(nid, limit=10)
    Recommend.fetch_and_build({:lnid => nid},limit)
  end

  def self.for_token(token, limit=10)
    Recommend.fetch_and_build({:token => token},limit)
  end

  private

  def self.fetch_and_build(finder, limit)
    limit = Util.limit(limit,10)
    Recommend.find(finder).limit(limit).map{|rec|
      Recommend.build(rec)
    }
  end

  def self.build(rec)
    rec = Recommend.clean(rec)
    Recommend.image(rec)
    Recommend.location(rec)
    Recommend.user(rec)
    rec
  end
  
  def self.clean(rec)
    rec = Util.de_nid(rec, '_id')
    rec = Util.nidify(rec, 'recommendation_nid', 'rnid')
    rec
  end
  
  def self.image(rec)
    inid = rec.delete('inid')
    rec[:image] = Image.for_nid(inid) if inid.present?
    rec
  end

  def self.location(rec)
    location_nid = rec.delete('lnid')
    rec[:location] = Location.compact_detail_for_nid(location_nid) || {}
    rec
  end

  def self.user(rec)
    user_nid = rec.delete('unid')
    rec[:user] = User.for_nid(user_nid)
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
