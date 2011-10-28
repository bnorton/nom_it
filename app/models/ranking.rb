class Ranking < MongoRuby
  
  #        | nid | user_id | average | some description
  attr_accessor :nid, :uid, :value, :text
  
  def self.dbcollection
    "rankings"
  end
  
  def self.new
  
end
