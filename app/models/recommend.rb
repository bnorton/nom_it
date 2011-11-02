require 'mongo_ruby'

class Recommend < MongoRuby
  # rid => recommendation_id
  # uid => user_id
  # 
  attr_accessor :rid,   :uid,    :uname,     :to_uid
  attr_accessor :token, :name,   :city
  attr_accessor :text,  :title,  :lat,       :lng
  attr_accessor :time,  :iid,    :lid
    
  def self.dbcollection
    "recommends"
  end

  def self.removed_content_message
    "the user has removed this recommendation."
  end
  
  def self.create(recommendation,followers)
    return false if recommendation.blank? || followers.blank?
    r = recommendation
    followers.each do |follower|
      self.save({
        :rid    => r['id'],
        :uid    => r['user_id'],
        :uname  => r['user_name'],
        :to_uid => follower.user_id,
        :token  => r['token'],
        :lid    => r['location_id'],
        :name   => r['name'],
        :city   => r['city'],
        :text   => r['text'],
        :title  => r['title'],
        :lat    => r['lat'],
        :lng    => r['lng'],
        :time   => r['time'] || Time.now,
        :iid    => r['image_id']
      })
    end
  end
  
  def self.destroy()
    
  end
  
  def self.by_user_id(id)
    Recommend.find({:uid => id.to_i})
  end
  
  def self.for_user_id(id)
    Recommend.find({:to_uid => id.to_i})
  end
  
  def self.for_location_id(id)
    Recommend.find({:lid => id.to_i})
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
