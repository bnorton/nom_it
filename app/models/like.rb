class Like < MongoRuby
  
  ############ user_id  |  location_id  |  recommendation_id
  attr_accessor :uid,         :lid,              :rid
  
  def self.dbcollection
    "likes"
  end
  
  
  
end