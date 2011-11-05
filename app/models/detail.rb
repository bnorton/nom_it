class Detail < MongoRuby
  
    #        | token | recommendation_id | user_id
  attr_accessor :t, :r
  
  def self.dbcollection
    "tokens"
  end
  
  def self.new_token(token,recommendation_id)
    Detail.save({:_id => token, :r => recommendation_id})
  end
  
  def self.for_whatever(key,item,lim)
    lim = lim > 50 ? 50 : lim < 5 ? 5 : lim
    found = Detail.find({key => item}).limit(lim)
    Util.parse(found,{:key=>:token})
  end
  
  def self.for_token(token,lim=20)
    Detail.for_whatever(:_id,token,lim)
  end
  
  def self.for_recommendation(rid,lim=20)
    Detail.for_whatever(:r,rid,lim)
  end
  
end