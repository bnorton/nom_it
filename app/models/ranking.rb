class Ranking < MongoRuby
  
  #        | nid | user_id | average | count
  attr_accessor :nid, :uid, :value
  
  def self.dbcollection
    "rankings"
  end
  
end
