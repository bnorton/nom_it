require 'mongo_ruby'

class Recommend < MongoRuby
  
  attr_accessor :id,    :user_id,:user_name, :to_user_id
  attr_accessor :token, :name,   :city
  attr_accessor :text,  :title,  :lat,       :lng
  attr_accessor :time,  :image,  :location_id
    
  def self.dbcollection
    "recommends"
  end
  
  def self.create(recommendation,followers)
    return false if recommendation.blank? || followers.blank?
    r = recommendation
    followers.each do |follower|
      self.save({
        :id        => r['id'],
        :user_id   => r['user_id'],
        :user_name => r['user_name'],
        :to_user_id=> follower.user_id,
        :token     => r['token'],
        :location_id => r['location_id'],
        :name      => r['name'],
        :city      => r['city'],
        :text      => r['text'],
        :title     => r['title'],
        :lat       => r['lat'],
        :lng       => r['lng'],
        :time      => r['time'] || Time.now,
        :image_id  => r['image_id']
      })
    end
  end
  
  def self.destroy()
    
  end
  
  def self.by_user_id(id)
    self.collection.find({:user_id => id})
  end
  
  def self.for_user_id(id)
    self.collection.find({:to_user_id => id})
  end
  
  def self.about_location_id(id)
    self.collection.find({:location_id => id})
  end
  
  def self.for_token(token)
    self.collection.find({:token => token})
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
